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
        VStack(spacing: 0) {
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

                Spacer()

                Image(systemName: "lock.rotation")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.omAccent)
                    .padding(.bottom, Spacing.l)

                Text("Forgot your password?")
                    .font(.serif(28))
                    .foregroundStyle(Color.omText)
                    .multilineTextAlignment(.center)

                Text("Please contact support or create a new account.")
                    .font(.omCallout)
                    .foregroundStyle(Color.omTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.s)
                    .padding(.horizontal, Spacing.xl)

                Spacer()

                OMButton(label: "Close", variant: .secondary, size: .lg, fullWidth: true) {
                    showForgotPassword = false
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.bottom, Spacing.x4)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, Spacing.l)
        .presentationBackground(Color.omBg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}
