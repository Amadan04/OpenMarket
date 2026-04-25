import SwiftUI

struct PrivacySecurityView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("privacy_showLocation")     private var showLocation     = true
    @AppStorage("privacy_showOnlineStatus") private var showOnlineStatus = true

    @State private var showChangePassword = false
    @State private var showActiveSessions = false
    @State private var showDeleteConfirm  = false

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 40, height: 40)
                            .background(Color.omBgElevated)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACCOUNT").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text("Privacy & security").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        privacyGroup(header: "Privacy", rows: [
                            ("Show location", "Buyers can see your approximate area", $showLocation),
                            ("Show online status", "Let others see when you're active", $showOnlineStatus),
                        ])

                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("SECURITY").font(.omMicro).foregroundStyle(Color.omTextSubtle).padding(.leading, 4)
                            VStack(spacing: 0) {
                                Button { showChangePassword = true } label: {
                                    actionRow(icon: "lock.rotation", label: "Change password", color: Color.omAccent)
                                }
                                .buttonStyle(.plain)
                                Divider().padding(.leading, 56)
                                Button { showActiveSessions = true } label: {
                                    actionRow(icon: "rectangle.portrait.and.arrow.right", label: "Active sessions", color: Color.omAccent)
                                }
                                .buttonStyle(.plain)
                                Divider().padding(.leading, 56)
                                Button { showDeleteConfirm = true } label: {
                                    actionRow(icon: "trash", label: "Delete account", color: Color.omDanger)
                                }
                                .buttonStyle(.plain)
                            }
                            .background(Color.omBgElevated)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                            .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordSheet()
        }
        .sheet(isPresented: $showActiveSessions) {
            ActiveSessionsSheet()
        }
        .confirmationDialog("Delete your account?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete account", role: .destructive) {
                showDeleteConfirm = false
                showDeleteAccountSheet = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove your account, listings, and all your data. This cannot be undone.")
        }
        .sheet(isPresented: $showDeleteAccountSheet) {
            DeleteAccountSheet { authViewModel.logout() }
        }
    }

    @State private var showDeleteAccountSheet = false

    private func privacyGroup(header: String, rows: [(String, String, Binding<Bool>)]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(header.uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle).padding(.leading, 4)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                    HStack(spacing: Spacing.m) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.0).font(.inter(15, weight: .medium)).foregroundStyle(Color.omText)
                            Text(row.1).font(.inter(12)).foregroundStyle(Color.omTextMuted)
                        }
                        Spacer()
                        Toggle("", isOn: row.2).labelsHidden().tint(Color.omAccent)
                    }
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.m)
                    if idx < rows.count - 1 { Divider().padding(.leading, Spacing.l) }
                }
            }
            .background(Color.omBgElevated)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
        }
    }

    private func actionRow(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(label).font(.inter(15, weight: .medium)).foregroundStyle(color)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(Color.omTextSubtle)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.m)
    }
}

// MARK: - Change Password Sheet

private struct ChangePasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var current  = ""
    @State private var newPass  = ""
    @State private var confirm  = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var success = false

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3).fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5).padding(.top, Spacing.m)

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.omText).frame(width: 32, height: 32)
                            .background(Color.omBgSunken).clipShape(Circle())
                    }
                    Spacer()
                    Text("Change password").font(.inter(16, weight: .bold)).foregroundStyle(Color.omText)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)
                .padding(.bottom, Spacing.s)

                if success {
                    VStack(spacing: Spacing.l) {
                        Spacer()
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 56)).foregroundStyle(Color.omOk)
                        Text("Password updated").font(.serif(24)).foregroundStyle(Color.omText)
                        Text("Your password has been changed successfully.")
                            .font(.omBody).foregroundStyle(Color.omTextMuted).multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.x4)
                        Spacer()
                        OMButton(label: "Done", size: .lg, fullWidth: true) { dismiss() }
                            .padding(.horizontal, Spacing.xl).padding(.bottom, Spacing.xl)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: Spacing.l) {
                            OMField(label: "Current password", text: $current, isSecure: true)
                            OMField(label: "New password", text: $newPass, isSecure: true)
                            OMField(label: "Confirm new password", text: $confirm, isSecure: true)

                            if let err = errorMessage {
                                Text(err).font(.omCaption).foregroundStyle(Color.omDanger)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.l)
                        .padding(.bottom, Spacing.xl)
                    }

                    VStack {
                        OMButton(label: "Update password", size: .lg, fullWidth: true, icon: "lock.fill", isLoading: isLoading) {
                            Task { await submit() }
                        }
                        .disabled(current.isEmpty || newPass.isEmpty || confirm.isEmpty)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.m)
                    .background(Color.omBg)
                    .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func submit() async {
        guard newPass == confirm else {
            errorMessage = "New passwords don't match."
            return
        }
        guard newPass.count >= 8 else {
            errorMessage = "New password must be at least 8 characters."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            struct Body: Encodable { let current_password, new_password: String }
            try await APIClient.shared.requestVoid("/auth/password", method: "PATCH",
                body: Body(current_password: current, new_password: newPass))
            withAnimation { success = true }
        } catch let APIError.serverError(msg) {
            errorMessage = msg
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}

// MARK: - Active Sessions Sheet

private struct ActiveSessionsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3).fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5).padding(.top, Spacing.m)

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.omText).frame(width: 32, height: 32)
                            .background(Color.omBgSunken).clipShape(Circle())
                    }
                    Spacer()
                    Text("Active sessions").font(.inter(16, weight: .bold)).foregroundStyle(Color.omText)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)

                VStack(spacing: Spacing.l) {
                    Spacer()
                    Image(systemName: "iphone")
                        .font(.system(size: 48)).foregroundStyle(Color.omAccent)
                    Text("This device").font(.serif(22)).foregroundStyle(Color.omText)
                    VStack(spacing: Spacing.s) {
                        Text("iPhone · iOS 17").font(.inter(14)).foregroundStyle(Color.omTextMuted)
                        Text("Active now · Bahrain").font(.inter(13)).foregroundStyle(Color.omTextSubtle)
                    }
                    Text("You are only signed in on this device.")
                        .font(.inter(13)).foregroundStyle(Color.omTextMuted)
                        .padding(.top, Spacing.m)
                    Spacer()
                    OMButton(label: "Done", variant: .secondary, size: .lg, fullWidth: true) { dismiss() }
                        .padding(.horizontal, Spacing.xl).padding(.bottom, Spacing.xl)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Delete Account Sheet

private struct DeleteAccountSheet: View {
    var onDeleted: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var password   = ""
    @State private var isLoading  = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3).fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5).padding(.top, Spacing.m)

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.omText).frame(width: 32, height: 32)
                            .background(Color.omBgSunken).clipShape(Circle())
                    }
                    Spacer()
                    Text("Delete account").font(.inter(16, weight: .bold)).foregroundStyle(Color.omDanger)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)
                .padding(.bottom, Spacing.s)

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        HStack(spacing: Spacing.m) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18)).foregroundStyle(Color.omDanger)
                            Text("This will permanently delete your account, all your listings, and your data.")
                                .font(.inter(13)).foregroundStyle(Color.omTextMuted)
                        }
                        .padding(Spacing.l)
                        .background(Color.omDanger.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omDanger.opacity(0.2), lineWidth: 1))

                        OMField(label: "Enter your password to confirm", text: $password, isSecure: true)

                        if let err = errorMessage {
                            Text(err).font(.omCaption).foregroundStyle(Color.omDanger)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.l)
                    .padding(.bottom, Spacing.xl)
                }

                VStack {
                    OMButton(label: "Delete my account", variant: .danger, size: .lg, fullWidth: true,
                             icon: "trash", isLoading: isLoading) {
                        Task { await deleteAccount() }
                    }
                    .disabled(password.isEmpty)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .background(Color.omBg)
                .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
            }
        }
        .presentationDetents([.medium])
    }

    private func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            struct Body: Encodable { let password: String }
            try await APIClient.shared.requestVoid("/auth/account", method: "DELETE",
                body: Body(password: password))
            onDeleted()
        } catch let APIError.serverError(msg) {
            errorMessage = msg
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
    }
}
