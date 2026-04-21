import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProductListViewModel()
    @State private var showSearch = false
    @State private var showFilter = false

    private let categories = Constants.Categories.all

    var body: some View {
        NavigationStack {
            ZStack {
                Color.omBg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin").font(.system(size: 10)).foregroundStyle(Color.omTextMuted)
                                    Text("Nearby").font(.inter(12, weight: .medium)).foregroundStyle(Color.omTextMuted)
                                }
                                HStack(spacing: 0) {
                                    Text("Hey, \(authViewModel.currentUser?.name.components(separatedBy: " ").first ?? "there") ")
                                        .font(.serif(30))
                                        .foregroundStyle(Color.omText)
                                    Text("—").font(.serif(30, italic: true)).foregroundStyle(Color.omAccent)
                                }
                            }
                            Spacer()
                            AvatarView(initial: authViewModel.currentUser?.name.prefix(1).description ?? "?", size: 42)
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.l)
                        .padding(.bottom, Spacing.m)

                        // Search bar
                        HStack(spacing: Spacing.m) {
                            HStack(spacing: Spacing.m) {
                                Image(systemName: "magnifyingglass").font(.system(size: 17)).foregroundStyle(Color.omTextMuted)
                                Text("What are you looking for?").font(.omCallout).foregroundStyle(Color.omTextSubtle)
                                Spacer()
                                Button {
                                    showFilter = true
                                } label: {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.omText)
                                        .frame(width: 32, height: 32)
                                        .background(Color.omBgSunken)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, Spacing.l)
                            .frame(height: 48)
                            .background(Color.omBgElevated)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.omBorder, lineWidth: 1))
                            .onTapGesture { showSearch = true }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.m)

                        // Category chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.s) {
                                ForEach(categories, id: \.self) { cat in
                                    let emoji = categoryEmoji(cat)
                                    OMChip(label: cat, active: viewModel.selectedCategory == cat, emoji: emoji, large: true)
                                        .onTapGesture {
                                            viewModel.selectedCategory = cat
                                            Task { await viewModel.applyFilters() }
                                        }
                                }
                            }
                            .padding(.horizontal, Spacing.xl)
                        }
                        .padding(.bottom, Spacing.m)

                        // Featured banner
                        HStack(spacing: Spacing.l) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("NEARBY TODAY")
                                    .font(.omMicro)
                                    .foregroundStyle(.white.opacity(0.7))
                                Text("\(viewModel.products.count) items near you.")
                                    .font(.serif(22))
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.clay400)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(Spacing.xl)
                        .background(Color.stone700)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.l)

                        // Section header
                        HStack {
                            Text("Near you").font(.inter(17, weight: .bold)).foregroundStyle(Color.omText)
                            Spacer()
                            NavigationLink("See map") {}
                                .font(.inter(13, weight: .semibold))
                                .foregroundStyle(Color.omAccent)
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.m)

                        // Masonry 2-col grid
                        if viewModel.isLoading {
                            ProgressView().padding(.top, Spacing.x4)
                        } else if viewModel.products.isEmpty {
                            emptyState
                        } else {
                            MasonryGrid(products: viewModel.products)
                                .padding(.horizontal, Spacing.xl)
                        }
                    }
                    .padding(.bottom, 100)
                }
                .refreshable { await viewModel.loadProducts() }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showFilter) {
                FilterSheetView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showSearch) {
                SearchView()
            }
        }
        .task { await viewModel.loadProducts() }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "magnifyingglass").font(.system(size: 40)).foregroundStyle(Color.omTextSubtle)
            Text("No listings found").font(.omTitle3).foregroundStyle(Color.omText)
            Text("Try adjusting your filters.").font(.omBody).foregroundStyle(Color.omTextMuted)
        }
        .padding(.top, Spacing.x4)
    }

    private func categoryEmoji(_ cat: String) -> String? {
        let map: [String: String] = [
            "All": "✨", "Vehicles": "🚗", "Property": "🏠", "Mobile": "📱",
            "Electronics": "📷", "Furniture": "🪑", "Fashion": "👕",
            "Sports": "🚲", "Books": "📚", "Other": "📦"
        ]
        return map[cat]
    }
}

// MARK: - 2-column grid
private struct MasonryGrid: View {
    let products: [Product]

    private var gridHeight: CGFloat {
        let rows = ceil(Double(products.count) / 2.0)
        return rows * 220 + (rows - 1) * Spacing.m
    }

    var body: some View {
        GeometryReader { geo in
            let colWidth = (geo.size.width - Spacing.m) / 2
            LazyVGrid(columns: [GridItem(.fixed(colWidth)), GridItem(.fixed(colWidth))], spacing: Spacing.m) {
                ForEach(products) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                    } label: {
                        ProductCardView(product: product)
                            .frame(width: colWidth)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(height: gridHeight)
    }
}
