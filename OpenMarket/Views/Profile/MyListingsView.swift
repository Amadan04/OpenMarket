import SwiftUI

struct MyListingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = "Active"
    @State private var soldSheetProduct: Product? = nil
    @Environment(\.dismiss) private var dismiss

    private let tabs = ["Active", "Sold", "Drafts"]

    private var activeListings: [Product] { viewModel.myListings.filter { !$0.isSold } }
    private var soldListings: [Product]   { viewModel.myListings.filter { $0.isSold } }

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
                    let totalViews = viewModel.myListings.reduce(0) { $0 + $1.viewCount }
                    let stats: [(String, String)] = [
                        ("\(activeListings.count)", "Active"),
                        ("\(soldListings.count)", "Sold"),
                        ("\(totalViews)", "Views"),
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
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(0..<5, id: \.self) { _ in SkeletonRowView() }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.s)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            let list = selectedTab == "Active" ? activeListings : selectedTab == "Sold" ? soldListings : []
                            if list.isEmpty {
                                emptyState
                            } else {
                                ForEach(list) { product in
                                    listingRow(product)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.m)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $soldSheetProduct) { product in
            SoldConfirmationSheet(product: product) { updated in
                if let idx = viewModel.myListings.firstIndex(where: { $0.id == updated.id }) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.myListings[idx] = updated
                    }
                }
            }
        }
        .navigationDestination(item: $navigateTo) { product in
            EditListingView(product: product, onDelete: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.myListings.removeAll { $0.id == product.id }
                }
            })
        }
        .task {
            if let id = authViewModel.currentUser?.id {
                await viewModel.loadMyListings(userID: id)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: selectedTab == "Sold" ? "bag.badge.checkmark" : "tag")
                .font(.system(size: 40))
                .foregroundStyle(Color.omTextMuted)
            Text(selectedTab == "Sold" ? "No sold items yet" : "No listings yet")
                .font(.omBodyMed)
                .foregroundStyle(Color.omTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func listingRow(_ product: Product) -> some View {
        HStack(spacing: Spacing.m) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Rectangle().fill(Color.cream200)
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))

                if product.isSold {
                    Text("SOLD")
                        .font(.inter(9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(Color.black.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(4)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(product.isSold ? Color.omTextMuted : Color.sage500)
                        .frame(width: 5, height: 5)
                    Text(product.isSold ? "SOLD" : "ACTIVE")
                        .font(.omMicro)
                        .foregroundStyle(product.isSold ? Color.omTextMuted : Color.sage500)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background((product.isSold ? Color.omTextMuted : Color.sage500).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Text(product.title).font(.inter(15, weight: .semibold)).foregroundStyle(Color.omText).lineLimit(1)
                Text(product.price.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                    .font(.inter(15, weight: .bold)).foregroundStyle(product.isSold ? Color.omTextMuted : Color.omAccent)
            }
            Spacer()

            if !product.isSold {
                VStack(spacing: Spacing.s) {
                    NavigationLink {
                        IncomingOffersView(product: product)
                    } label: {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.omAccent)
                            .frame(width: 32, height: 32)
                            .background(Color.omAccentSoft)
                            .clipShape(Circle())
                    }

                    Button {
                        soldSheetProduct = product
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.omAccent)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(Spacing.m)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
        .opacity(product.isSold ? 0.6 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture { navigateTo = product }
    }

    @State private var navigateTo: Product? = nil

}
