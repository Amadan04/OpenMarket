import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

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
                            Button("Forgot password?") {}
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

                    // Social buttons (UI only — no backend support)
                    HStack(spacing: Spacing.m) {
                        ForEach(["Apple", "Google", "Email"], id: \.self) { provider in
                            Text(provider)
                                .font(.inter(14, weight: .semibold))
                                .foregroundStyle(Color.omText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.omBgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.omBorder, lineWidth: 1))
                        }
                    }

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
    }
}
