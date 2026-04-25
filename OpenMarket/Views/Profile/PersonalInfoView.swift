import SwiftUI

struct PersonalInfoView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var name = ""
    @State private var phone = ""
    @State private var isSaving = false
    @State private var saved = false

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Nav
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
                        Text("Personal info").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                    Button(isEditing ? "Cancel" : "Edit") {
                        if isEditing {
                            name = authViewModel.currentUser?.name ?? ""
                            phone = ""
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isEditing.toggle()
                        }
                    }
                    .font(.inter(14, weight: .semibold))
                    .foregroundStyle(Color.omAccent)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                ScrollView {
                    VStack(spacing: Spacing.m) {
                        // Avatar
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(initial: authViewModel.currentUser?.name.prefix(1).description ?? "?", size: 80)
                            if isEditing {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white)
                                    .frame(width: 26, height: 26)
                                    .background(Color.omAccent)
                                    .clipShape(Circle())
                                    .offset(x: 4, y: 4)
                            }
                        }
                        .padding(.vertical, Spacing.l)
                        .animation(.spring(response: 0.3), value: isEditing)

                        if isEditing {
                            // Editable fields
                            OMField(label: "Full name", text: $name, placeholder: "Your name", leadingIcon: "person")
                            OMField(label: "Phone number", text: $phone, placeholder: "+973 XXXX XXXX", leadingIcon: "phone")
                                .keyboardType(.phonePad)

                            // Email — read only
                            readRow(icon: "envelope", label: "Email", value: authViewModel.currentUser?.email ?? "—", note: "Cannot be changed")

                            if saved {
                                HStack(spacing: Spacing.s) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.omOk)
                                    Text("Changes saved").font(.inter(14, weight: .semibold)).foregroundStyle(Color.omOk)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }

                            if let err = saveError {
                                HStack(spacing: Spacing.s) {
                                    Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Color.omError)
                                    Text(err).font(.inter(13)).foregroundStyle(Color.omError)
                                }
                                .transition(.opacity)
                            }

                            OMButton(label: "Save changes", size: .lg, fullWidth: true, isLoading: isSaving) {
                                save()
                            }
                            .padding(.top, Spacing.s)

                        } else {
                            // Read-only rows
                            infoRow(icon: "person", label: "Full name", value: authViewModel.currentUser?.name ?? "—")
                            infoRow(icon: "envelope", label: "Email", value: authViewModel.currentUser?.email ?? "—")
                            infoRow(icon: "phone", label: "Phone number", value: phone.isEmpty ? "Not set" : phone)
                            infoRow(icon: "calendar", label: "Member since", value: authViewModel.currentUser?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "—")
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, 100)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isEditing)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            name = authViewModel.currentUser?.name ?? ""
        }
    }

    @State private var saveError: String? = nil

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSaving = true
        saveError = nil
        Task {
            defer { isSaving = false }
            do {
                try await authViewModel.updateProfile(name: trimmed)
                withAnimation(.spring(response: 0.4)) {
                    saved = true
                    isEditing = false
                }
                Task {
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                    withAnimation { saved = false }
                }
            } catch let APIError.serverError(msg) {
                saveError = msg
            } catch {
                saveError = "Failed to save changes."
            }
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.omAccent)
                .frame(width: 40, height: 40)
                .background(Color.omAccentSoft)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.omCaption).foregroundStyle(Color.omTextMuted)
                Text(value).font(.omBodyMed).foregroundStyle(Color.omText)
            }
            Spacer()
        }
        .padding(Spacing.l)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
    }

    private func readRow(icon: String, label: String, value: String, note: String) -> some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.omTextMuted)
                .frame(width: 40, height: 40)
                .background(Color.omBgSunken)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.omCaption).foregroundStyle(Color.omTextMuted)
                Text(value).font(.omBodyMed).foregroundStyle(Color.omText)
                Text(note).font(.inter(11)).foregroundStyle(Color.omTextSubtle)
            }
            Spacer()
        }
        .padding(Spacing.l)
        .background(Color.omBgSunken)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
    }
}
