import SwiftUI

struct MyListingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = "Active"
    @Environment(\.dismiss) private var dismiss

    private let tabs = ["Active", "Sold", "Drafts"]

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
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
                        Text("YOUR SHOP").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text("My listings").font(.serif(30)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                    NavigationLink { AddProductView() } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.omAccent)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                // Stats banner
                HStack(spacing: 0) {
                    let stats: [(String, String)] = [
                        ("\(viewModel.myListings.count)", "Active"),
                        ("0", "Sold"),
                        ("—", "Views"),
                        ("—", "Messages")
                    ]
                    ForEach(Array(stats.enumerated()), id: \.offset) { idx, s in
                        VStack(spacing: 2) {
                            Text(s.0).font(.serif(24)).foregroundStyle(.white)
                            Text(s.1.uppercased()).font(.omMicro).foregroundStyle(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        if idx < stats.count - 1 {
                            Rectangle().fill(.white.opacity(0.12)).frame(width: 1, height: 40)
                        }
                    }
                }
                .padding(Spacing.m)
                .background(Color.stone700)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.m)

                // Tabs
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        Button {
                            withAnimation { selectedTab = tab }
                        } label: {
                            VStack(spacing: Spacing.s) {
                                Text(tab).font(.inter(14, weight: .semibold))
                                    .foregroundStyle(selectedTab == tab ? Color.omText : Color.omTextMuted)
                                Rectangle()
                                    .fill(selectedTab == tab ? Color.omAccent : Color.clear)
                                    .frame(height: 2)
                            }
                            .padding(.vertical, Spacing.m)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                Divider()

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(viewModel.myListings) { product in
                                listingRow(product)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.m)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            if let id = authViewModel.currentUser?.id {
                await viewModel.loadMyListings(userID: id)
            }
        }
    }

    private func listingRow(_ product: Product) -> some View {
        HStack(spacing: Spacing.m) {
            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Rectangle().fill(Color.cream200)
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle().fill(Color.sage500).frame(width: 5, height: 5)
                    Text("ACTIVE")
                        .font(.omMicro)
                        .foregroundStyle(Color.sage500)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Color.sage500.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Text(product.title).font(.inter(15, weight: .semibold)).foregroundStyle(Color.omText).lineLimit(1)
                Text(product.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                    .font(.inter(15, weight: .bold)).foregroundStyle(Color.omAccent)
            }
            Spacer()
            Image(systemName: "ellipsis").foregroundStyle(Color.omTextMuted)
        }
        .padding(Spacing.m)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
    }
}
