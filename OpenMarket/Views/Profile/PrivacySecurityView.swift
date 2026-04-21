import SwiftUI

struct PrivacySecurityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showLocation = true
    @State private var showOnlineStatus = true

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
                            Text("SECURITY".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle).padding(.leading, 4)
                            VStack(spacing: 0) {
                                actionRow(icon: "lock.rotation", label: "Change password", color: Color.omAccent)
                                Divider().padding(.leading, 56)
                                actionRow(icon: "rectangle.portrait.and.arrow.right", label: "Active sessions", color: Color.omAccent)
                                Divider().padding(.leading, 56)
                                actionRow(icon: "trash", label: "Delete account", color: Color.omDanger)
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
    }

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
