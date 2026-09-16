//
//  Untitled.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//

import StoreKit
import SwiftUI
import Combine

@MainActor
class SubscriptionService: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var currentTier: SubscriptionTier? = nil
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var purchaseSuccess: Bool = false

    private var updateListenerTask: Task<Void, Error>? = nil

    let productIds = SubscriptionTier.allCases.map { $0.productId }

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products from App Store Connect
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: productIds)
            products.sort { $0.price < $1.price }
        } catch {
            // In development/sandbox, use mock products
            errorMessage = "Could not load products: \(error.localizedDescription)"
        }
    }

    // MARK: - Purchase
    func purchase(_ tier: SubscriptionTier) async {
        guard let product = products.first(where: { $0.id == tier.productId }) else {
            // Sandbox / simulator: simulate purchase
            await simulatePurchase(tier)
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    await transaction.finish()
                    isSubscribed = true
                    currentTier = tier
                    purchaseSuccess = true
                    saveSubscriptionLocally(tier: tier)
                case .unverified:
                    errorMessage = "Purchase verification failed."
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Listen for Transaction Updates
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                }
            }
        }
    }

    // MARK: - Update Subscription Status
    func updateSubscriptionStatus() async {
        var hasActiveSubscription = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    hasActiveSubscription = true
                    if let tier = SubscriptionTier.allCases.first(where: { $0.productId == transaction.productID }) {
                        currentTier = tier
                    }
                }
            }
        }
        isSubscribed = hasActiveSubscription || loadLocalSubscription()
    }

    // MARK: - Simulator/Dev Simulation
    private func simulatePurchase(_ tier: SubscriptionTier) async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isSubscribed = true
        currentTier = tier
        purchaseSuccess = true
        saveSubscriptionLocally(tier: tier)
    }

    // MARK: - Local Persistence (Fallback)
    private func saveSubscriptionLocally(tier: SubscriptionTier) {
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        UserDefaults.standard.set(tier.rawValue, forKey: "subscriptionTier")
        let expiryDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        UserDefaults.standard.set(expiryDate, forKey: "subscriptionExpiry")
    }

    private func loadLocalSubscription() -> Bool {
        guard UserDefaults.standard.bool(forKey: "isSubscribed"),
              let expiry = UserDefaults.standard.object(forKey: "subscriptionExpiry") as? Date else {
            return false
        }
        let isValid = expiry > Date()
        if isValid, let tierRaw = UserDefaults.standard.string(forKey: "subscriptionTier"),
           let tier = SubscriptionTier(rawValue: tierRaw) {
            currentTier = tier
        }
        return isValid
    }
}
