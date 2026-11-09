//
//  Verifyemailview.swift
//  GYM
//
//  Created by Mohamed ahmed on 30/10/2026.




import SwiftUI
import Combine

// MARK: - Email verification screen
// Shown after Register (or Login with an unverified account).
// Polls Firebase every 3 seconds and enters the app automatically once verified.
struct VerifyEmailView: View {
    @EnvironmentObject var auth: FirebaseAuthManager
    @EnvironmentObject var lm: LanguageManager

    @State private var cooldown = 0
    @State private var tick = 0
    @State private var message = ""
    @State private var isChecking = false
    @State private var isSending = false

    private let lime = Color(red: 0.88, green: 1.0, blue: 0.2)
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let cooldownSeconds = 60

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(colors: [Color(red: 0.1, green: 0.4, blue: 0.2).opacity(0.45), .clear],
                           center: .top, startRadius: 0, endRadius: 500)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    icon
                    titleBlock
                    statusRow
                    stepsCard
                    if !message.isEmpty { messageRow }
                    verifyButton
                    resendButton
                    logoutButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 70)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { updateCooldown() }
        .onReceive(timer) { _ in
            updateCooldown()
            tick += 1
            if tick % 3 == 0 {
                Task { await auth.refreshVerification() }
            }
        }
    }

    // MARK: Pieces
    private var icon: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [lime.opacity(0.25), Color.green.opacity(0.15)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 120, height: 120)
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 52))
                .foregroundStyle(LinearGradient(colors: [lime, .green], startPoint: .top, endPoint: .bottom))
        }
        .shadow(color: .green.opacity(0.4), radius: 24)
    }

    private var titleBlock: some View {
        VStack(spacing: 10) {
            Text(lm.isArabic ? "تحقق من بريدك الإلكتروني" : "Verify your email")
                .font(.title2).bold()
                .foregroundColor(.white)
            Text(lm.isArabic ? "أرسلنا رسالة تأكيد إلى" : "We sent a verification email to")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.55))
            Text(auth.email)
                .font(.headline)
                .foregroundColor(lime)
        }
        .multilineTextAlignment(.center)
    }

    private var statusRow: some View {
        Group {
            if let error = auth.lastVerificationError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            } else if let sent = auth.lastVerificationSent {
                Label(lm.isArabic ? "أُرسلت الرسالة الساعة \(timeString(sent))"
                                  : "Email sent at \(timeString(sent))",
                      systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Label(lm.isArabic ? "لم تُرسل رسالة بعد، اضغط إعادة الإرسال"
                                  : "No email sent yet, tap Resend",
                      systemImage: "info.circle.fill")
                    .foregroundColor(.orange)
            }
        }
        .font(.caption)
        .multilineTextAlignment(.center)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private var stepsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            stepRow(1, lm.isArabic ? "افتح بريدك الإلكتروني" : "Open your email inbox")
            stepRow(2, lm.isArabic ? "اضغط على رابط التأكيد في الرسالة" : "Tap the verification link in the message")
            stepRow(3, lm.isArabic ? "ارجع للتطبيق وسندخلك تلقائياً" : "Come back and we'll sign you in automatically")
            Text(lm.isArabic ? "لو مش لاقي الرسالة، شوف مجلد Spam أو Junk."
                             : "Can't find it? Check your Spam or Junk folder.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.45))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }

    private func stepRow(_ number: Int, _ text: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption).bold()
                .foregroundColor(.black)
                .frame(width: 24, height: 24)
                .background(Circle().fill(lime))
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
        }
    }

    private var messageRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle.fill").foregroundColor(.orange)
            Text(message).font(.caption).foregroundColor(.orange)
            Spacer()
        }
    }

    private var verifyButton: some View {
        Button(action: checkNow) {
            ZStack {
                if isChecking {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text(lm.isArabic ? "تم التحقق، دخّلني" : "I've verified, continue")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(LinearGradient(colors: [lime, .green], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(16)
        }
        .disabled(isChecking)
    }

    private var resendButton: some View {
        Button(action: resend) {
            Group {
                if isSending {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if cooldown > 0 {
                    Text(lm.isArabic ? "إعادة الإرسال بعد \(cooldown) ثانية" : "Resend in \(cooldown)s")
                } else {
                    Text(lm.isArabic ? "إعادة إرسال رسالة التأكيد" : "Resend verification email")
                }
            }
            .font(.subheadline)
            .foregroundColor(cooldown > 0 ? .white.opacity(0.35) : .white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
        }
        .disabled(cooldown > 0 || isSending)
    }

    private var logoutButton: some View {
        Button(action: { auth.logout() }) {
            Text(lm.isArabic ? "استخدام بريد آخر / تسجيل الخروج" : "Use a different email / Sign out")
                .font(.caption)
                .foregroundColor(.green)
        }
    }

    // MARK: Actions
    private func updateCooldown() {
        guard let last = auth.lastVerificationSent else { cooldown = 0; return }
        cooldown = max(0, cooldownSeconds - Int(Date().timeIntervalSince(last)))
    }

    private func checkNow() {
        message = ""
        isChecking = true
        Task {
            let verified = await auth.refreshVerification()
            await MainActor.run {
                isChecking = false
                if !verified {
                    message = lm.isArabic
                        ? "لم يتم التحقق بعد. اضغط على الرابط في الرسالة أولاً."
                        : "Not verified yet. Tap the link in the email first."
                }
            }
        }
    }

    private func resend() {
        message = ""
        isSending = true
        Task {
            do {
                try await auth.sendVerificationEmail()
                await MainActor.run {
                    isSending = false
                    updateCooldown()
                    message = lm.isArabic ? "تم إرسال رسالة التأكيد" : "Verification email sent"
                }
            } catch {
                await MainActor.run {
                    isSending = false
                    message = (lm.isArabic ? "تعذر الإرسال: " : "Couldn't send: ") + error.localizedDescription
                }
            }
        }
    }
}
