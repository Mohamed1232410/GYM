//
//  FirebaseLoginView.swift
//  GYM
//
//  Created by Mohamed ahmed on 15/10/2026.



//import SwiftUI
//import FirebaseAuth
//
//struct FirebaseLoginView: View {
//    @EnvironmentObject var lm: LanguageManager
//    @ObservedObject var authManager: FirebaseAuthManager
//    @State private var isLogin = true
//    @State private var name = ""
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//    @State private var showPassword = false
//    @State private var showConfirm = false
//    @State private var errorMessage = ""
//    @State private var isLoading = false
//    @State private var showResetAlert = false
//    @State private var resetEmail = ""
//    @State private var resetSent = false
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            RadialGradient(colors: [Color(red:0.1,green:0.4,blue:0.2).opacity(0.45),.clear],
//                           center: .top, startRadius: 0, endRadius: 500).ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//
//                    // Logo
//                    VStack(spacing: 10) {
//                        Image("fitbody_logo")
//                            .resizable().scaledToFit()
//                            .frame(width: 110, height: 110)
//                            .clipShape(Circle())
//                            .shadow(color: .green.opacity(0.5), radius: 24)
//                            .padding(.top, 56)
//                        HStack(spacing: 0) {
//                            Text("FIT").font(.system(size: 34, weight: .black, design: .rounded))
//                                .foregroundColor(Color(red:0.88,green:1.0,blue:0.2))
//                            Text("BODY").font(.system(size: 34, weight: .light, design: .rounded))
//                                .foregroundColor(.white)
//                        }
//                        Text(lm.isArabic ? "رفيقك الرياضي الشامل" : "Your Complete Fitness Companion")
//                            .font(.subheadline).foregroundColor(.white.opacity(0.45))
//                    }.padding(.bottom, 36)
//
//                    // Segment
//                    HStack(spacing: 0) {
//                        segmentBtn(lm.isArabic ? "تسجيل الدخول" : "Login", selected: isLogin)
//                            { withAnimation { isLogin = true; errorMessage = "" } }
//                        segmentBtn(lm.isArabic ? "إنشاء حساب" : "Register", selected: !isLogin)
//                            { withAnimation { isLogin = false; errorMessage = "" } }
//                    }
//                    .background(Color.white.opacity(0.07)).cornerRadius(14)
//                    .padding(.horizontal, 24).padding(.bottom, 28)
//
//                    // Fields
//                    VStack(spacing: 14) {
//                        if !isLogin {
//                            authField("person.fill", lm.isArabic ? "الاسم الكامل" : "Full Name",
//                                      $name, secure: false)
//                        }
//                        authField("envelope.fill", lm.isArabic ? "البريد الإلكتروني" : "Email",
//                                  $email, secure: false, keyboard: .emailAddress)
//                        authField("lock.fill", lm.isArabic ? "كلمة المرور" : "Password",
//                                  $password, secure: !showPassword, toggle: $showPassword)
//                        if !isLogin {
//                            authField("lock.shield.fill", lm.isArabic ? "تأكيد كلمة المرور" : "Confirm Password",
//                                      $confirmPassword, secure: !showConfirm, toggle: $showConfirm)
//                        }
//                        if !errorMessage.isEmpty {
//                            HStack(spacing: 6) {
//                                Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
//                                Text(errorMessage).font(.caption).foregroundColor(.red)
//                            }.padding(.horizontal, 4)
//                        }
//                        if isLogin {
//                            HStack {
//                                Spacer()
//                                Button(lm.isArabic ? "نسيت كلمة المرور؟" : "Forgot Password?") {
//                                    showResetAlert = true
//                                }.font(.caption).foregroundColor(.green)
//                            }
//                        }
//                    }.padding(.horizontal, 24)
//
//                    // Submit Button
//                    Button(action: handleSubmit) {
//                        ZStack {
//                            if isLoading {
//                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
//                            } else {
//                                Text(isLogin
//                                     ? (lm.isArabic ? "تسجيل الدخول" : "Login")
//                                     : (lm.isArabic ? "إنشاء الحساب" : "Create Account"))
//                                    .font(.headline).foregroundColor(.black)
//                            }
//                        }
//                        .frame(maxWidth: .infinity).frame(height: 54)
//                        .background(LinearGradient(
//                            colors: [Color(red:0.88,green:1.0,blue:0.2), .green],
//                            startPoint: .leading, endPoint: .trailing))
//                        .cornerRadius(16)
//                    }
//                    .disabled(isLoading)
//                    .padding(.horizontal, 24).padding(.top, 22)
//
//                    // Divider
//                    HStack {
//                        Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
//                        Text(lm.isArabic ? "أو" : "OR").font(.caption)
//                            .foregroundColor(.white.opacity(0.35)).padding(.horizontal, 12)
//                        Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
//                    }.padding(.horizontal, 24).padding(.vertical, 18)
//
//                    // Guest
//                    Button(action: { authManager.isLoggedIn = true }) {
//                        HStack(spacing: 8) {
//                            Image(systemName: "person.crop.circle.badge.questionmark")
//                                .foregroundColor(.white.opacity(0.55))
//                            Text(lm.isArabic ? "الدخول كضيف" : "Continue as Guest")
//                                .font(.subheadline).foregroundColor(.white.opacity(0.55))
//                        }
//                        .frame(maxWidth: .infinity).frame(height: 50)
//                        .overlay(RoundedRectangle(cornerRadius: 14)
//                            .stroke(Color.white.opacity(0.13), lineWidth: 1))
//                    }.padding(.horizontal, 24)
//
//                    // Switch
//                    HStack(spacing: 4) {
//                        Text(isLogin
//                             ? (lm.isArabic ? "ليس لديك حساب؟" : "Don't have an account?")
//                             : (lm.isArabic ? "لديك حساب؟" : "Already have an account?"))
//                            .font(.caption).foregroundColor(.white.opacity(0.45))
//                        Button(isLogin
//                               ? (lm.isArabic ? "سجّل الآن" : "Register")
//                               : (lm.isArabic ? "تسجيل الدخول" : "Login")) {
//                            withAnimation { isLogin.toggle(); errorMessage = "" }
//                        }.font(.caption).bold().foregroundColor(.green)
//                    }.padding(.top, 18).padding(.bottom, 44)
//                }
//            }
//        }
//        .preferredColorScheme(.dark)
//        .alert(lm.isArabic ? "استعادة كلمة المرور" : "Reset Password",
//               isPresented: $showResetAlert) {
//            TextField(lm.isArabic ? "البريد الإلكتروني" : "Email", text: $resetEmail)
//                .keyboardType(.emailAddress).autocapitalization(.none)
//            Button(lm.isArabic ? "إرسال" : "Send") { sendReset() }
//            Button(lm.isArabic ? "إلغاء" : "Cancel", role: .cancel) {}
//        } message: {
//            Text(lm.isArabic ? "أدخل بريدك لاستلام رابط إعادة التعيين"
//                             : "Enter your email to receive a reset link")
//        }
//        .alert(lm.isArabic ? "تم الإرسال ✓" : "Sent ✓", isPresented: $resetSent) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text(lm.isArabic ? "تحقق من بريدك الإلكتروني" : "Check your email inbox")
//        }
//    }
//
//    func handleSubmit() {
//        errorMessage = ""; isLoading = true
//        Task {
//            do {
//                if isLogin {
//                    try await authManager.login(
//                        email: email.trimmingCharacters(in: .whitespaces).lowercased(),
//                        password: password)
//                } else {
//                    guard password == confirmPassword else {
//                        await MainActor.run {
//                            errorMessage = lm.isArabic ? "كلمة المرور غير متطابقة" : "Passwords do not match"
//                            isLoading = false
//                        }
//                        return
//                    }
//                    try await authManager.register(
//                        name: name.trimmingCharacters(in: .whitespaces),
//                        email: email.trimmingCharacters(in: .whitespaces).lowercased(),
//                        password: password)
//                }
//            } catch {
//                await MainActor.run { errorMessage = friendlyError(error) }
//            }
//            await MainActor.run { isLoading = false }
//        }
//    }
//
//    func sendReset() {
//        Task {
//            try? await authManager.resetPassword(email: resetEmail.lowercased())
//            await MainActor.run { resetSent = true }
//        }
//    }
//
//    func friendlyError(_ error: Error) -> String {
//        let code = AuthErrorCode(rawValue: (error as NSError).code)
//        switch code {
//        case .emailAlreadyInUse: return lm.isArabic ? "البريد مستخدم مسبقاً" : "Email already in use"
//        case .wrongPassword:     return lm.isArabic ? "كلمة مرور خاطئة" : "Wrong password"
//        case .userNotFound:      return lm.isArabic ? "الحساب غير موجود" : "Account not found"
//        case .invalidEmail:      return lm.isArabic ? "بريد إلكتروني غير صالح" : "Invalid email"
//        case .weakPassword:      return lm.isArabic ? "كلمة مرور ضعيفة (6 أحرف على الأقل)" : "Weak password (min 6 chars)"
//        case .networkError:      return lm.isArabic ? "تحقق من الاتصال" : "Check your internet connection"
//        default:                 return error.localizedDescription
//        }
//    }
//
//    @ViewBuilder
//    func segmentBtn(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Text(title).font(.subheadline).bold()
//                .foregroundColor(selected ? .black : .white.opacity(0.45))
//                .frame(maxWidth: .infinity).frame(height: 44)
//                .background(selected
//                    ? LinearGradient(colors: [Color(red:0.88,green:1.0,blue:0.2), .green],
//                                     startPoint: .leading, endPoint: .trailing)
//                    : LinearGradient(colors: [.clear,.clear], startPoint: .leading, endPoint: .trailing))
//                .cornerRadius(12)
//        }
//    }
//
//    @ViewBuilder
//    func authField(_ icon: String, _ placeholder: String, _ binding: Binding<String>,
//                   secure: Bool, keyboard: UIKeyboardType = .default,
//                   toggle: Binding<Bool>? = nil) -> some View {
//        HStack(spacing: 14) {
//            Image(systemName: icon).font(.subheadline).foregroundColor(.green).frame(width: 20)
//            if secure {
//                SecureField(placeholder, text: binding).font(.body).foregroundColor(.white)
//                    .autocapitalization(.none).autocorrectionDisabled()
//            } else {
//                TextField(placeholder, text: binding).font(.body).foregroundColor(.white)
//                    .keyboardType(keyboard).autocapitalization(.none).autocorrectionDisabled()
//            }
//            if let t = toggle {
//                Button(action: { t.wrappedValue.toggle() }) {
//                    Image(systemName: t.wrappedValue ? "eye.slash.fill" : "eye.fill")
//                        .font(.caption).foregroundColor(.white.opacity(0.35))
//                }
//            }
//        }
//        .padding(.horizontal, 16).frame(height: 56)
//        .background(Color.white.opacity(0.07)).cornerRadius(14)
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.09), lineWidth: 1))
//    }
//}





//فيه مشكله في الكود

//import SwiftUI
//import FirebaseAuth
//
//// MARK: - Login / Register screen
//struct FirebaseLoginView: View {
//    @EnvironmentObject var auth: FirebaseAuthManager
//    @EnvironmentObject var lm: LanguageManager
//
//    @State private var isLogin = true
//    @State private var name = ""
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//    @State private var showPassword = false
//    @State private var errorMessage = ""
//    @State private var isLoading = false
//    @State private var showResetAlert = false
//    @State private var resetEmail = ""
//    @State private var resetSent = false
//
//    private let lime = Color(red: 0.88, green: 1.0, blue: 0.2)
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            RadialGradient(colors: [Color(red: 0.1, green: 0.4, blue: 0.2).opacity(0.45), .clear],
//                           center: .top, startRadius: 0, endRadius: 500)
//                .ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//                    languageButton
//                    logoHeader
//                    modePicker
//                    fieldsSection
//                    submitButton
//                    guestSection
//                    switchModeRow
//                }
//            }
//        }
//        .preferredColorScheme(.dark)
//        .alert(lm.isArabic ? "استعادة كلمة المرور" : "Reset Password", isPresented: $showResetAlert) {
//            TextField(lm.isArabic ? "البريد الإلكتروني" : "Email", text: $resetEmail)
//                .keyboardType(.emailAddress)
//                .textInputAutocapitalization(.never)
//            Button(lm.isArabic ? "إرسال" : "Send") { sendReset() }
//            Button(lm.isArabic ? "إلغاء" : "Cancel", role: .cancel) {}
//        } message: {
//            Text(lm.isArabic ? "أدخل بريدك لاستلام رابط إعادة التعيين" : "Enter your email to receive a reset link")
//        }
//        .alert(lm.isArabic ? "تم الإرسال" : "Sent", isPresented: $resetSent) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text(lm.isArabic ? "تحقق من بريدك الإلكتروني" : "Check your email inbox")
//        }
//    }
//
//    // MARK: Sections
//    private var languageButton: some View {
//        HStack {
//            Button(action: { lm.toggle() }) {
//                HStack(spacing: 6) {
//                    Image(systemName: "globe")
//                    Text(lm.isArabic ? "English" : "العربية")
//                }
//                .font(.caption).bold()
//                .foregroundColor(.white.opacity(0.8))
//                .padding(.horizontal, 12).padding(.vertical, 8)
//                .background(Color.white.opacity(0.1))
//                .clipShape(Capsule())
//            }
//            Spacer()
//        }
//        .padding(.horizontal, 24).padding(.top, 16)
//    }
//
//    private var logoHeader: some View {
//        VStack(spacing: 10) {
//            logoImage
//                .frame(width: 110, height: 110)
//                .clipShape(Circle())
//                .shadow(color: .green.opacity(0.5), radius: 24)
//                .padding(.top, 24)
//
//            HStack(spacing: 0) {
//                Text("FIT")
//                    .font(.system(size: 34, weight: .black, design: .rounded))
//                    .foregroundColor(lime)
//                Text("BODY")
//                    .font(.system(size: 34, weight: .light, design: .rounded))
//                    .foregroundColor(.white)
//            }
//            Text(lm.isArabic ? "رفيقك الرياضي الشامل" : "Your Complete Fitness Companion")
//                .font(.subheadline)
//                .foregroundColor(.white.opacity(0.45))
//        }
//        .padding(.bottom, 32)
//    }
//
//    @ViewBuilder
//    private var logoImage: some View {
//        if UIImage(named: "fitbody_logo") != nil {
//            Image("fitbody_logo").resizable().scaledToFit()
//        } else {
//            ZStack {
//                Circle().fill(Color(red: 0.45, green: 0.3, blue: 0.9))
//                Text("FB").font(.system(size: 40, weight: .black, design: .rounded)).foregroundColor(.white)
//            }
//        }
//    }
//
//    private var modePicker: some View {
//        HStack(spacing: 0) {
//            FBSegment(title: lm.isArabic ? "تسجيل الدخول" : "Login", selected: isLogin) {
//                withAnimation { isLogin = true; errorMessage = "" }
//            }
//            FBSegment(title: lm.isArabic ? "إنشاء حساب" : "Register", selected: !isLogin) {
//                withAnimation { isLogin = false; errorMessage = "" }
//            }
//        }
//        .background(Color.white.opacity(0.07))
//        .cornerRadius(14)
//        .padding(.horizontal, 24)
//        .padding(.bottom, 24)
//    }
//
//    private var fieldsSection: some View {
//        VStack(spacing: 14) {
//            if !isLogin {
//                FBTextField(icon: "person.fill",
//                            placeholder: lm.isArabic ? "الاسم الكامل" : "Full Name",
//                            text: $name)
//            }
//            FBTextField(icon: "envelope.fill",
//                        placeholder: lm.isArabic ? "البريد الإلكتروني" : "Email",
//                        text: $email, keyboard: .emailAddress)
//            FBTextField(icon: "lock.fill",
//                        placeholder: lm.isArabic ? "كلمة المرور" : "Password",
//                        text: $password, isSecure: !showPassword, showEye: true, eyeOn: $showPassword)
//            if !isLogin {
//                FBTextField(icon: "lock.shield.fill",
//                            placeholder: lm.isArabic ? "تأكيد كلمة المرور" : "Confirm Password",
//                            text: $confirmPassword, isSecure: !showPassword)
//            }
//
//            if !errorMessage.isEmpty {
//                HStack(spacing: 6) {
//                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
//                    Text(errorMessage).font(.caption).foregroundColor(.red)
//                    Spacer()
//                }
//            }
//
//            if isLogin {
//                HStack {
//                    Spacer()
//                    Button(lm.isArabic ? "نسيت كلمة المرور؟" : "Forgot Password?") {
//                        resetEmail = email
//                        showResetAlert = true
//                    }
//                    .font(.caption).foregroundColor(.green)
//                }
//            }
//        }
//        .padding(.horizontal, 24)
//    }
//
//    private var submitButton: some View {
//        Button(action: handleSubmit) {
//            ZStack {
//                if isLoading {
//                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
//                } else {
//                    Text(isLogin
//                         ? (lm.isArabic ? "تسجيل الدخول" : "Login")
//                         : (lm.isArabic ? "إنشاء الحساب" : "Create Account"))
//                        .font(.headline)
//                        .foregroundColor(.black)
//                }
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: 54)
//            .background(LinearGradient(colors: [lime, .green], startPoint: .leading, endPoint: .trailing))
//            .cornerRadius(16)
//        }
//        .disabled(isLoading)
//        .padding(.horizontal, 24)
//        .padding(.top, 22)
//    }
//
//    private var guestSection: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
//                Text(lm.isArabic ? "أو" : "OR")
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.35))
//                    .padding(.horizontal, 12)
//                Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
//            }
//            .padding(.horizontal, 24)
//            .padding(.vertical, 18)
//
//            Button(action: { auth.continueAsGuest() }) {
//                HStack(spacing: 8) {
//                    Image(systemName: "person.crop.circle")
//                    Text(lm.isArabic ? "الدخول كضيف" : "Continue as Guest")
//                        .font(.subheadline)
//                }
//                .foregroundColor(.white.opacity(0.6))
//                .frame(maxWidth: .infinity)
//                .frame(height: 50)
//                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
//            }
//            .padding(.horizontal, 24)
//        }
//    }
//
//    private var switchModeRow: some View {
//        HStack(spacing: 4) {
//            Text(isLogin
//                 ? (lm.isArabic ? "ليس لديك حساب؟" : "Don't have an account?")
//                 : (lm.isArabic ? "لديك حساب؟" : "Already have an account?"))
//                .font(.caption)
//                .foregroundColor(.white.opacity(0.45))
//            Button(isLogin
//                   ? (lm.isArabic ? "سجّل الآن" : "Register")
//                   : (lm.isArabic ? "تسجيل الدخول" : "Login")) {
//                withAnimation { isLogin.toggle(); errorMessage = "" }
//            }
//            .font(.caption).bold()
//            .foregroundColor(.green)
//        }
//        .padding(.top, 18)
//        .padding(.bottom, 44)
//    }
//
//    // MARK: Actions
//    private func handleSubmit() {
//        errorMessage = ""
//        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
//        let cleanName = name.trimmingCharacters(in: .whitespaces)
//
//        guard cleanEmail.contains("@"), cleanEmail.contains(".") else {
//            errorMessage = lm.isArabic ? "بريد إلكتروني غير صالح" : "Invalid email"
//            return
//        }
//        guard password.count >= 6 else {
//            errorMessage = lm.isArabic ? "كلمة المرور 6 أحرف على الأقل" : "Password must be at least 6 characters"
//            return
//        }
//        if !isLogin {
//            guard !cleanName.isEmpty else {
//                errorMessage = lm.isArabic ? "أدخل اسمك" : "Enter your name"
//                return
//            }
//            guard password == confirmPassword else {
//                errorMessage = lm.isArabic ? "كلمة المرور غير متطابقة" : "Passwords do not match"
//                return
//            }
//        }
//
//        isLoading = true
//        Task {
//            do {
//                if isLogin {
//                    try await auth.login(email: cleanEmail, password: password)
//                } else {
//                    try await auth.register(name: cleanName, email: cleanEmail, password: password)
//                }
//            } catch {
//                await MainActor.run { errorMessage = friendlyError(error) }
//            }
//            await MainActor.run { isLoading = false }
//        }
//    }
//
//    private func sendReset() {
//        let target = resetEmail.trimmingCharacters(in: .whitespaces).lowercased()
//        guard !target.isEmpty else { return }
//        Task {
//            try? await auth.resetPassword(email: target)
//            await MainActor.run { resetSent = true }
//        }
//    }
//
//    private func friendlyError(_ error: Error) -> String {
////        let code = AuthErrorCode.Code(rawValue: (error as NSError).code)
//        
//        let code = AuthErrorCode(rawValue: (error as NSError).code)
//        switch code {
//        case .emailAlreadyInUse:
//            return lm.isArabic ? "البريد مستخدم مسبقاً" : "Email already in use"
//        case .wrongPassword, .invalidCredential:
//            return lm.isArabic ? "البريد أو كلمة المرور غير صحيحة" : "Incorrect email or password"
//        case .userNotFound:
//            return lm.isArabic ? "الحساب غير موجود" : "Account not found"
//        case .invalidEmail:
//            return lm.isArabic ? "بريد إلكتروني غير صالح" : "Invalid email"
//        case .weakPassword:
//            return lm.isArabic ? "كلمة المرور ضعيفة" : "Weak password"
//        case .networkError:
//            return lm.isArabic ? "تحقق من الاتصال بالإنترنت" : "Check your internet connection"
//        case .tooManyRequests:
//            return lm.isArabic ? "محاولات كثيرة، حاول لاحقاً" : "Too many attempts, try later"
//        case .operationNotAllowed:
//            return lm.isArabic ? "فعّل Email/Password من Firebase Console" : "Enable Email/Password in Firebase Console"
//        default:
//            return error.localizedDescription
//        }
//    }
//}
//
//// MARK: - Components
//struct FBSegment: View {
//    let title: String
//    let selected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.subheadline).bold()
//                .foregroundColor(selected ? .black : .white.opacity(0.5))
//                .frame(maxWidth: .infinity)
//                .frame(height: 44)
//                .background(
//                    selected
//                    ? AnyView(LinearGradient(colors: [Color(red: 0.88, green: 1.0, blue: 0.2), .green],
//                                             startPoint: .leading, endPoint: .trailing))
//                    : AnyView(Color.clear)
//                )
//                .cornerRadius(12)
//        }
//    }
//}
//
//struct FBTextField: View {
//    let icon: String
//    let placeholder: String
//    @Binding var text: String
//    var keyboard: UIKeyboardType = .default
//    var isSecure: Bool = false
//    var showEye: Bool = false
//    var eyeOn: Binding<Bool>? = nil
//
//    var body: some View {
//        HStack(spacing: 14) {
//            Image(systemName: icon)
//                .font(.subheadline)
//                .foregroundColor(.green)
//                .frame(width: 20)
//
//            Group {
//                if isSecure {
//                    SecureField(placeholder, text: $text)
//                } else {
//                    TextField(placeholder, text: $text)
//                        .keyboardType(keyboard)
//                }
//            }
//            .foregroundColor(.white)
//            .textInputAutocapitalization(.never)
//            .autocorrectionDisabled()
//
//            if showEye, let eyeOn = eyeOn {
//                Button(action: { eyeOn.wrappedValue.toggle() }) {
//                    Image(systemName: eyeOn.wrappedValue ? "eye.slash.fill" : "eye.fill")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.4))
//                }
//            }
//        }
//        .padding(.horizontal, 16)
//        .frame(height: 56)
//        .background(Color.white.opacity(0.07))
//        .cornerRadius(14)
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
//    }
//}






import SwiftUI
import FirebaseAuth

// MARK: - Login / Register screen
struct FirebaseLoginView: View {
    @EnvironmentObject var auth: FirebaseAuthManager
    @EnvironmentObject var lm: LanguageManager

    @State private var isLogin = true
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showResetAlert = false
    @State private var resetEmail = ""
    @State private var resetSent = false

    private let lime = Color(red: 0.88, green: 1.0, blue: 0.2)
    private let allowGuest = true   // set to false to force login

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(colors: [Color(red: 0.1, green: 0.4, blue: 0.2).opacity(0.45), .clear],
                           center: .top, startRadius: 0, endRadius: 500)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    languageButton
                    logoHeader
                    modePicker
                    fieldsSection
                    submitButton
                    if allowGuest { guestSection }
                    switchModeRow
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert(lm.isArabic ? "استعادة كلمة المرور" : "Reset Password", isPresented: $showResetAlert) {
            TextField(lm.isArabic ? "البريد الإلكتروني" : "Email", text: $resetEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            Button(lm.isArabic ? "إرسال" : "Send") { sendReset() }
            Button(lm.isArabic ? "إلغاء" : "Cancel", role: .cancel) {}
        } message: {
            Text(lm.isArabic ? "أدخل بريدك لاستلام رابط إعادة التعيين" : "Enter your email to receive a reset link")
        }
        .alert(lm.isArabic ? "تم الإرسال" : "Sent", isPresented: $resetSent) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(lm.isArabic ? "تحقق من بريدك الإلكتروني" : "Check your email inbox")
        }
    }

    // MARK: Sections
    private var languageButton: some View {
        HStack {
            Button(action: { lm.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                    Text(lm.isArabic ? "English" : "العربية")
                }
                .font(.caption).bold()
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 24).padding(.top, 16)
    }

    private var logoHeader: some View {
        VStack(spacing: 10) {
            logoImage
                .frame(width: 110, height: 110)
                .clipShape(Circle())
                .shadow(color: .green.opacity(0.5), radius: 24)
                .padding(.top, 24)

            HStack(spacing: 0) {
                Text("FIT")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(lime)
                Text("BODY")
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .foregroundColor(.white)
            }
            Text(lm.isArabic ? "رفيقك الرياضي الشامل" : "Your Complete Fitness Companion")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.45))
        }
        .padding(.bottom, 32)
    }

    @ViewBuilder
    private var logoImage: some View {
        if UIImage(named: "fitbody_logo") != nil {
            Image("fitbody_logo").resizable().scaledToFit()
        } else {
            ZStack {
                Circle().fill(Color(red: 0.45, green: 0.3, blue: 0.9))
                Text("FB").font(.system(size: 40, weight: .black, design: .rounded)).foregroundColor(.white)
            }
        }
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            FBSegment(title: lm.isArabic ? "تسجيل الدخول" : "Login", selected: isLogin) {
                withAnimation { isLogin = true; errorMessage = "" }
            }
            FBSegment(title: lm.isArabic ? "إنشاء حساب" : "Register", selected: !isLogin) {
                withAnimation { isLogin = false; errorMessage = "" }
            }
        }
        .background(Color.white.opacity(0.07))
        .cornerRadius(14)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            if !isLogin {
                FBTextField(icon: "person.fill",
                            placeholder: lm.isArabic ? "الاسم الكامل" : "Full Name",
                            text: $name)
            }
            FBTextField(icon: "envelope.fill",
                        placeholder: lm.isArabic ? "البريد الإلكتروني" : "Email",
                        text: $email, keyboard: .emailAddress)
            FBTextField(icon: "lock.fill",
                        placeholder: lm.isArabic ? "كلمة المرور" : "Password",
                        text: $password, isSecure: !showPassword, showEye: true, eyeOn: $showPassword)
            if !isLogin {
                FBTextField(icon: "lock.shield.fill",
                            placeholder: lm.isArabic ? "تأكيد كلمة المرور" : "Confirm Password",
                            text: $confirmPassword, isSecure: !showPassword)
            }

            if !errorMessage.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                    Text(errorMessage).font(.caption).foregroundColor(.red)
                    Spacer()
                }
            }

            if isLogin {
                HStack {
                    Spacer()
                    Button(lm.isArabic ? "نسيت كلمة المرور؟" : "Forgot Password?") {
                        resetEmail = email
                        showResetAlert = true
                    }
                    .font(.caption).foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private var submitButton: some View {
        Button(action: handleSubmit) {
            ZStack {
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text(isLogin
                         ? (lm.isArabic ? "تسجيل الدخول" : "Login")
                         : (lm.isArabic ? "إنشاء الحساب" : "Create Account"))
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(LinearGradient(colors: [lime, .green], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(16)
        }
        .disabled(isLoading)
        .padding(.horizontal, 24)
        .padding(.top, 22)
    }

    private var guestSection: some View {
        VStack(spacing: 0) {
            HStack {
                Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
                Text(lm.isArabic ? "أو" : "OR")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.horizontal, 12)
                Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)

            Button(action: { auth.continueAsGuest() }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle")
                    Text(lm.isArabic ? "الدخول كضيف" : "Continue as Guest")
                        .font(.subheadline)
                }
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
            }
            .padding(.horizontal, 24)
        }
    }

    private var switchModeRow: some View {
        HStack(spacing: 4) {
            Text(isLogin
                 ? (lm.isArabic ? "ليس لديك حساب؟" : "Don't have an account?")
                 : (lm.isArabic ? "لديك حساب؟" : "Already have an account?"))
                .font(.caption)
                .foregroundColor(.white.opacity(0.45))
            Button(isLogin
                   ? (lm.isArabic ? "سجّل الآن" : "Register")
                   : (lm.isArabic ? "تسجيل الدخول" : "Login")) {
                withAnimation { isLogin.toggle(); errorMessage = "" }
            }
            .font(.caption).bold()
            .foregroundColor(.green)
        }
        .padding(.top, 18)
        .padding(.bottom, 44)
    }

    // MARK: Actions
    private func handleSubmit() {
        errorMessage = ""
        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        let cleanName = name.trimmingCharacters(in: .whitespaces)

        guard cleanEmail.contains("@"), cleanEmail.contains(".") else {
            errorMessage = lm.isArabic ? "بريد إلكتروني غير صالح" : "Invalid email"
            return
        }
        guard password.count >= 6 else {
            errorMessage = lm.isArabic ? "كلمة المرور 6 أحرف على الأقل" : "Password must be at least 6 characters"
            return
        }
        if !isLogin {
            guard !cleanName.isEmpty else {
                errorMessage = lm.isArabic ? "أدخل اسمك" : "Enter your name"
                return
            }
            guard password == confirmPassword else {
                errorMessage = lm.isArabic ? "كلمة المرور غير متطابقة" : "Passwords do not match"
                return
            }
        }

        isLoading = true
        Task {
            do {
                if isLogin {
                    try await auth.login(email: cleanEmail, password: password)
                } else {
                    try await auth.register(name: cleanName, email: cleanEmail, password: password)
                }
            } catch {
                await MainActor.run { errorMessage = friendlyError(error) }
            }
            await MainActor.run { isLoading = false }
        }
    }

    private func sendReset() {
        let target = resetEmail.trimmingCharacters(in: .whitespaces).lowercased()
        guard !target.isEmpty else { return }
        Task {
            try? await auth.resetPassword(email: target)
            await MainActor.run { resetSent = true }
        }
    }

    private func friendlyError(_ error: Error) -> String {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .emailAlreadyInUse:
            return lm.isArabic ? "البريد مستخدم مسبقاً" : "Email already in use"
        case .wrongPassword, .invalidCredential:
            return lm.isArabic ? "البريد أو كلمة المرور غير صحيحة" : "Incorrect email or password"
        case .userNotFound:
            return lm.isArabic ? "الحساب غير موجود" : "Account not found"
        case .invalidEmail:
            return lm.isArabic ? "بريد إلكتروني غير صالح" : "Invalid email"
        case .weakPassword:
            return lm.isArabic ? "كلمة المرور ضعيفة" : "Weak password"
        case .networkError:
            return lm.isArabic ? "تحقق من الاتصال بالإنترنت" : "Check your internet connection"
        case .tooManyRequests:
            return lm.isArabic ? "محاولات كثيرة، حاول لاحقاً" : "Too many attempts, try later"
        case .operationNotAllowed:
            return lm.isArabic ? "فعّل Email/Password من Firebase Console" : "Enable Email/Password in Firebase Console"
        case .internalError:
            return internalDetails(error)
        default:
            let ns = error as NSError
            print("Firebase Auth error:", ns.code, ns.domain, ns.userInfo)
            return "\(error.localizedDescription) (code \(ns.code))"
        }
    }

    // Pulls the real server/keychain reason out of Firebase's generic "internal error"
    private func internalDetails(_ error: Error) -> String {
        let ns = error as NSError
        print("Firebase Auth INTERNAL error:", ns.code, ns.domain, ns.userInfo)

        if let response = ns.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any],
           let message = response["message"] as? String {
            return message
        }
        if let underlying = ns.userInfo[NSUnderlyingErrorKey] as? NSError {
            if underlying.domain == "FIRAuthInternalErrorDomain" {
                return lm.isArabic
                    ? "فشل الاتصال بخدمة Firebase. تأكد من تفعيل Authentication و Email/Password في Firebase Console"
                    : "Firebase request failed. Make sure Authentication and Email/Password are enabled in Firebase Console"
            }
            return "\(underlying.localizedDescription) (\(underlying.domain) \(underlying.code))"
        }
        return "Firebase internal error (17999)"
    }
}

// MARK: - Components
struct FBSegment: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).bold()
                .foregroundColor(selected ? .black : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    selected
                    ? AnyView(LinearGradient(colors: [Color(red: 0.88, green: 1.0, blue: 0.2), .green],
                                             startPoint: .leading, endPoint: .trailing))
                    : AnyView(Color.clear)
                )
                .cornerRadius(12)
        }
    }
}

struct FBTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var showEye: Bool = false
    var eyeOn: Binding<Bool>? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.green)
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                }
            }
            .foregroundColor(.white)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            if showEye, let eyeOn = eyeOn {
                Button(action: { eyeOn.wrappedValue.toggle() }) {
                    Image(systemName: eyeOn.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.white.opacity(0.07))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
