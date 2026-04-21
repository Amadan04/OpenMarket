import SwiftUI

struct PersonalInfoView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var email: String = ""

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
                        Text("Personal info").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                ScrollView {
                    VStack(spacing: Spacing.m) {
                        AvatarView(initial: authViewModel.currentUser?.name.prefix(1).description ?? "?", size: 72)
                            .padding(.vertical, Spacing.l)

                        infoRow(icon: "person", label: "Full name", value: authViewModel.currentUser?.name ?? "—")
                        infoRow(icon: "envelope", label: "Email", value: authViewModel.currentUser?.email ?? "—")
                        infoRow(icon: "phone", label: "Phone number", value: "Not set")
                        infoRow(icon: "calendar", label: "Member since", value: authViewModel.currentUser?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "—")
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
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
}
