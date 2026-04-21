import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages = true
    @State private var newListings = true
    @State private var priceDrops = false
    @State private var reviews = true
    @State private var marketing = false

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
                        Text("Notifications").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        notifGroup(header: "Activity", rows: [
                            ("Messages", "New messages from buyers and sellers", $messages),
                            ("Reviews", "When someone leaves you a review", $reviews),
                        ])
                        notifGroup(header: "Listings", rows: [
                            ("New listings", "Items matching your saved searches", $newListings),
                            ("Price drops", "When saved items drop in price", $priceDrops),
                        ])
                        notifGroup(header: "General", rows: [
                            ("Marketing", "Tips, offers and updates from OpenMarket", $marketing),
                        ])
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func notifGroup(header: String, rows: [(String, String, Binding<Bool>)]) -> some View {
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
}
