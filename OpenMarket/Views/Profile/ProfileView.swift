import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showFavorites = false
    @State private var showMyListings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.omBg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Me")
                            .font(.serif(34))
                            .foregroundStyle(Color.omText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Spacing.xl)
                            .padding(.top, Spacing.l)
                            .padding(.bottom, Spacing.m)

                        // Profile card
                        HStack(spacing: Spacing.m) {
                            AvatarView(initial: authViewModel.currentUser?.name.prefix(1).description ?? "?", size: 60)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authViewModel.currentUser?.name ?? "")
                                    .font(.inter(17, weight: .bold))
                                    .foregroundStyle(Color.omText)
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill").font(.system(size: 11)).foregroundStyle(Color.omAccent)
                                    Text("4.8 · \(viewModel.myListings.count) listings · Member")
                                        .font(.inter(12))
                                        .foregroundStyle(Color.omTextMuted)
                                }
                                Button("View public profile →") {}
                                    .font(.inter(13, weight: .semibold))
                                    .foregroundStyle(Color.omAccent)
                                    .padding(.top, 2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Spacing.xl)
                        .background(Color.omBgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
                        .overlay(RoundedRectangle(cornerRadius: Radius.xl).stroke(Color.omBorder, lineWidth: 1))
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)

                        // Settings groups
                        settingsGroup(header: "Activity", rows: [
                            .init(emoji: "❤️", title: "Saved items", badge: nil, destination: AnyView(FavoritesView())),
                            .init(emoji: "🏷️", title: "My listings", badge: "\(viewModel.myListings.count) active", destination: AnyView(MyListingsView())),
                            .init(emoji: "⭐", title: "Reviews", badge: "\(viewModel.myReviews?.reviewsCount ?? 0)", destination: AnyView(ReviewsView(sellerID: authViewModel.currentUser?.id ?? 0))),
                        ])

                        settingsGroup(header: "Account", rows: [
                            .init(emoji: "👤", title: "Personal info", badge: nil, destination: nil),
                            .init(emoji: "📍", title: "Saved locations", badge: nil, destination: nil),
                            .init(emoji: "🔔", title: "Notifications", badge: nil, destination: nil),
                            .init(emoji: "🔒", title: "Privacy & security", badge: nil, destination: nil),
                        ])

                        settingsGroup(header: "Support", rows: [
                            .init(emoji: "❓", title: "Help center", badge: nil, destination: nil),
                            .init(emoji: "📄", title: "Terms & privacy", badge: nil, destination: nil),
                        ])

                        // Log out
                        Button {
                            authViewModel.logout()
                        } label: {
                            HStack(spacing: Spacing.m) {
                                Text("↩️")
                                    .frame(width: 32, height: 32)
                                    .background(Color(hex: "#FBE8E6"))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Text("Log out")
                                    .font(.inter(15, weight: .medium))
                                    .foregroundStyle(Color.omDanger)
                                Spacer()
                            }
                            .padding(Spacing.l)
                            .background(Color.omBgElevated)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                            .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            if let id = authViewModel.currentUser?.id {
                await viewModel.loadMyListings(userID: id)
                await viewModel.loadMyReviews(userID: id)
            }
        }
    }

    private struct SettingsRow {
        let emoji: String
        let title: String
        let badge: String?
        let destination: AnyView?
    }

    private func settingsGroup(header: String, rows: [SettingsRow]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(header.uppercased())
                .font(.omMicro)
                .foregroundStyle(Color.omTextSubtle)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { idx, row in
                    Group {
                        if let dest = row.destination {
                            NavigationLink { dest } label: { rowContent(row) }
                                .buttonStyle(.plain)
                        } else {
                            rowContent(row)
                        }
                    }
                    if idx < rows.count - 1 { Divider().padding(.leading, 56) }
                }
            }
            .background(Color.omBgElevated)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.xl)
    }

    private func rowContent(_ row: SettingsRow) -> some View {
        HStack(spacing: Spacing.m) {
            Text(row.emoji)
                .frame(width: 32, height: 32)
                .background(Color.omBgSunken)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            Text(row.title)
                .font(.inter(15, weight: .medium))
                .foregroundStyle(Color.omText)
            Spacer()
            if let badge = row.badge {
                Text(badge).font(.inter(13)).foregroundStyle(Color.omTextMuted)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundStyle(Color.omTextSubtle)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.m)
    }
}
