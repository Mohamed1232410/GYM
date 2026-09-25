//
//  Paywallview.swift
//  GYM
//
//  Created by Mohamed ahmed on 22/05/2026.
//

import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var selectedTier: SubscriptionTier = .annual
    @Environment(\.dismiss) var dismiss

    let features = [
        ("All Workout Plans", "figure.strengthtraining.traditional", Color.blue),
        ("Personalized Diet Plans", "fork.knife", Color.green),
        ("Exercise Library (50+ moves)", "books.vertical.fill", Color.orange),
        ("Progress Tracking & Charts", "chart.line.uptrend.xyaxis", Color.purple),
        ("Active Workout Tracker", "stopwatch.fill", Color.red),
        ("Body Measurements Log", "ruler.fill", Color.cyan),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    Text("Unlock FitPro")
                        .font(.largeTitle).bold()
                    Text("Your complete fitness companion")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)

                // Features
                VStack(spacing: 12) {
                    ForEach(features, id: \.0) { feature in
                        HStack(spacing: 14) {
                            Image(systemName: feature.1)
                                .font(.title3)
                                .foregroundColor(feature.2)
                                .frame(width: 36, height: 36)
                                .background(feature.2.opacity(0.12))
                                .cornerRadius(10)
                            Text(feature.0)
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.caption).bold()
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // Plan Selector
                VStack(spacing: 10) {
                    ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                        SubscriptionTierRow(tier: tier, isSelected: selectedTier == tier) {
                            selectedTier = tier
                        }
                    }
                }
                .padding(.horizontal)

                // Subscribe Button
                Button(action: {
                    Task {
                        await subscriptionService.purchase(selectedTier)
                    }
                }) {
                    HStack {
                        if subscriptionService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Start \(selectedTier.rawValue) Plan")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(subscriptionService.isLoading)
                .padding(.horizontal)

                if let error = subscriptionService.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                // Restore + Legal
                Button(action: {
                    Task { await subscriptionService.restorePurchases() }
                }) {
                    Text("Restore Purchases")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text("Subscriptions auto-renew. Cancel anytime in App Store settings. By subscribing you agree to our Terms of Service and Privacy Policy.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onChange(of: subscriptionService.purchaseSuccess) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

struct SubscriptionTierRow: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(tier.rawValue)
                            .font(.headline)
                        if let savings = tier.savings {
                            Text(savings)
                                .font(.caption2).bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                    Text(tier.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(tier.price)
                        .font(.headline)
                    Text(tier.pricePerMonth)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .green : .secondary)
                    .padding(.leading, 8)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(14)
            .overlay(isSelected ? RoundedRectangle(cornerRadius: 14).stroke(Color.green, lineWidth: 2) : nil)
        }
        .foregroundColor(.primary)
    }
}
