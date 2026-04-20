import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreed = false

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
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

                    Text("Create your account.")
                        .font(.serif(36))
                        .foregroundStyle(Color.omText)
                    Text("Takes about 30 seconds.")
                        .font(.omCallout)
                        .foregroundStyle(Color.omTextMuted)
                        .padding(.top, Spacing.s)

                    VStack(spacing: Spacing.m) {
                        OMField(label: "Full name", text: $name, placeholder: "Hana Al-Rashid")
                            .textContentType(.name)
                        OMField(label: "Email", text: $email, placeholder: "you@example.com")
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        OMField(label: "Create password", text: $password, placeholder: "At least 8 characters", isSecure: true)

                        // Terms
                        HStack(alignment: .top, spacing: Spacing.m) {
                            Button { agreed.toggle() } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(agreed ? Color.omAccent : Color.clear)
                                        .frame(width: 22, height: 22)
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(agreed ? Color.omAccent : Color.omBorderStrong, lineWidth: 1.5))
                                    if agreed {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .padding(.top, 2)

                            Group {
                                Text("I agree to OpenMarket's ")
                                + Text("Terms").foregroundColor(.omAccent).bold()
                                + Text(" and ")
                                + Text("Privacy Policy").foregroundColor(.omAccent).bold()
                                + Text(".")
                            }
                            .font(.inter(13))
                            .foregroundStyle(Color.omTextMuted)
                        }
                    }
                    .padding(.top, Spacing.x3)

                    if let err = authViewModel.errorMessage {
                        Text(err)
                            .font(.omCaption)
                            .foregroundStyle(Color.omDanger)
                            .padding(.top, Spacing.m)
                    }

                    OMButton(label: "Create account", size: .lg, fullWidth: true, isLoading: authViewModel.isLoading) {
                        Task { await authViewModel.register(name: name, email: email, password: password) }
                    }
                    .disabled(!agreed)
                    .opacity(agreed ? 1 : 0.5)
                    .padding(.top, Spacing.x3)
                }
                .padding(.horizontal, Spacing.xxl)
                .padding(.vertical, Spacing.l)
            }
        }
        .navigationBarHidden(true)
    }
}
