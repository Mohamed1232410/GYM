//
//  FirebaseAuthService.swift
//  GYM
//
//  Created by Mohamed ahmed on 18/10/2026.


import SwiftUI
import Combine
import FirebaseAuth

// MARK: - Firebase Auth Manager
// Email/Password auth + email verification + Guest mode.
final class FirebaseAuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isEmailVerified: Bool = false
    @Published var isGuest: Bool = UserDefaults.standard.bool(forKey: "fitbody_isGuest")
    @Published var lastVerificationSent: Date? =
        UserDefaults.standard.object(forKey: "fitbody_lastVerificationSent") as? Date
    @Published var lastVerificationError: String?

    /// Can enter the app: verified account, or guest
    var isAuthenticated: Bool { (currentUser != nil && isEmailVerified) || isGuest }
    /// Signed in but email not verified yet
    var needsVerification: Bool { currentUser != nil && !isEmailVerified }

    var displayName: String { currentUser?.displayName ?? "" }
    var email: String { currentUser?.email ?? "" }

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        currentUser = Auth.auth().currentUser
        isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isEmailVerified = user?.isEmailVerified ?? false
                if user != nil { self?.setGuest(false) }
            }
        }
    }

    deinit {
        if let handle = handle { Auth.auth().removeStateDidChangeListener(handle) }
    }

    // MARK: Account
    func register(name: String, email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let request = result.user.createProfileChangeRequest()
        request.displayName = name
        try await request.commitChanges()
        await MainActor.run { self.currentUser = Auth.auth().currentUser }
        try? await sendVerificationEmail()
    }

    func login(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    // MARK: Verification
    func sendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.sendEmailVerification()
            let now = Date()
            UserDefaults.standard.set(now, forKey: "fitbody_lastVerificationSent")
            await MainActor.run {
                self.lastVerificationSent = now
                self.lastVerificationError = nil
            }
        } catch {
            let code = (error as NSError).code
            await MainActor.run {
                self.lastVerificationError = "\(error.localizedDescription) (code \(code))"
            }
            throw error
        }
    }

    /// Reloads the user from Firebase and returns true if the email is now verified
    @discardableResult
    func refreshVerification() async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        try? await user.reload()
        let verified = Auth.auth().currentUser?.isEmailVerified ?? false
        await MainActor.run {
            self.currentUser = Auth.auth().currentUser
            self.isEmailVerified = verified
        }
        return verified
    }

    // MARK: Guest / Logout
    func continueAsGuest() { setGuest(true) }

    func logout() {
        try? Auth.auth().signOut()
        setGuest(false)
        currentUser = nil
        isEmailVerified = false
        lastVerificationSent = nil
        lastVerificationError = nil
        UserDefaults.standard.removeObject(forKey: "fitbody_lastVerificationSent")
    }

    private func setGuest(_ value: Bool) {
        isGuest = value
        UserDefaults.standard.set(value, forKey: "fitbody_isGuest")
    }
}
