import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showForgotPassword = false
    @State private var forgotEmail = ""
    @State private var forgotSent = false

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Back
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 40, height: 40)
                            .background(Color.omBgElevated)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                    }
                    .padding(.bottom, Spacing.xxl)

                    Text("Welcome back.")
                        .font(.serif(36))
                        .foregroundStyle(Color.omText)
                    Text("Sign in to pick up where you left off.")
                        .font(.omCallout)
                        .foregroundStyle(Color.omTextMuted)
                        .padding(.top, Spacing.s)

                    // Fields
                    VStack(spacing: Spacing.m) {
                        OMField(label: "Email", text: $email, placeholder: "you@example.com")
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        OMField(label: "Password", text: $password, placeholder: "At least 8 characters", isSecure: true)

                        HStack {
                            Spacer()
                            Button("Forgot password?") { showForgotPassword = true }
                                .font(.inter(14, weight: .medium))
                                .foregroundStyle(Color.omAccent)
                        }
                    }
                    .padding(.top, Spacing.x3)

                    if let err = authViewModel.errorMessage {
                        Text(err)
                            .font(.omCaption)
                            .foregroundStyle(Color.omDanger)
                            .padding(.top, Spacing.m)
                    }

                    OMButton(label: "Sign in", size: .lg, fullWidth: true, isLoading: authViewModel.isLoading) {
                        Task { await authViewModel.login(email: email, password: password) }
                    }
                    .padding(.top, Spacing.x3)

                    // Divider
                    HStack(spacing: Spacing.m) {
                        Rectangle().fill(Color.omBorder).frame(height: 1)
                        Text("OR CONTINUE WITH")
                            .font(.omMicro)
                            .foregroundStyle(Color.omTextSubtle)
                            .fixedSize()
                        Rectangle().fill(Color.omBorder).frame(height: 1)
                    }
                    .padding(.vertical, Spacing.x3)

                    // Social buttons
                    HStack(spacing: Spacing.m) {
                        ForEach(["Apple", "Google"], id: \.self) { provider in
                            ZStack(alignment: .topTrailing) {
                                Text(provider)
                                    .font(.inter(14, weight: .semibold))
                                    .foregroundStyle(Color.omTextSubtle)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.omBgSunken)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.omBorder, lineWidth: 1))
                                Text("Soon")
                                    .font(.omMicro)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.omTextSubtle)
                                    .clipShape(Capsule())
                                    .offset(x: -6, y: -8)
                            }
                        }
                    }
                    .allowsHitTesting(false)

                    // Sign up link
                    HStack(spacing: 4) {
                        Spacer()
                        Text("New here?").font(.inter(14)).foregroundStyle(Color.omTextMuted)
                        NavigationLink("Create account") { RegisterView() }
                            .font(.inter(14, weight: .semibold))
                            .foregroundStyle(Color.omAccent)
                        Spacer()
                    }
                    .padding(.top, Spacing.x3)
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.vertical, Spacing.l)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showForgotPassword) {
            forgotPasswordSheet
        }
    }

    private var forgotPasswordSheet: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button { showForgotPassword = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 40, height: 40)
                            .background(Color.omBgElevated)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                    }
                }
                .padding(.bottom, Spacing.xl)

                Text("Reset password.")
                    .font(.serif(36))
                    .foregroundStyle(Color.omText)
                Text("Enter your email and we'll send a reset link.")
                    .font(.omCallout)
                    .foregroundStyle(Color.omTextMuted)
                    .padding(.top, Spacing.s)

                if forgotSent {
                    HStack(spacing: Spacing.s) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.omOk)
                        Text("If an account exists, you'll receive a reset email.")
                            .font(.inter(14))
                            .foregroundStyle(Color.omText)
                    }
                    .padding(Spacing.m)
                    .background(Color.omOk.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    .padding(.top, Spacing.x3)
                } else {
                    OMField(label: "Email", text: $forgotEmail, placeholder: "you@example.com")
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding(.top, Spacing.x3)

                    OMButton(label: "Send reset link", size: .lg, fullWidth: true) {
                        forgotSent = true
                    }
                    .padding(.top, Spacing.x3)
                }

                Spacer()
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.l)
        }
    }
}
