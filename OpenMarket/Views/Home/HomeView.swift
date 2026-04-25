import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProductListViewModel()
    @ObservedObject private var recentStore = RecentlyViewedStore.shared
    @State private var showSearch = false
    @State private var showFilter = false

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
                                Button { showFilter = true } label: {
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
                        .padding(.bottom, Spacing.l)

                        // MARK: - Section cards

                        // Categories — full width
                        sectionCard(
                            title: "Categories",
                            subtitle: "Browse by type",
                            icon: "square.grid.2x2.fill",
                            bg: Color.stone700,
                            destination: AnyView(CategoryBrowserView())
                        )
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.m)

                        // Trending + Cheap — side by side
                        HStack(spacing: Spacing.m) {
                            sectionCard(
                                title: "Trending",
                                subtitle: "Most viewed",
                                icon: "flame.fill",
                                bg: Color.clay500,
                                destination: AnyView(SectionProductsView(title: "Trending", subtitle: "Most viewed", sort: "views"))
                            )
                            sectionCard(
                                title: "Cheap Finds",
                                subtitle: "Best prices",
                                icon: "tag.fill",
                                bg: Color.sage500,
                                destination: AnyView(SectionProductsView(title: "Cheap Finds", subtitle: "Best prices", sort: "price_asc"))
                            )
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.m)

                        // New Arrivals — full width
                        sectionCard(
                            title: "New Arrivals",
                            subtitle: "Just listed",
                            icon: "sparkles",
                            bg: Color.stone600,
                            destination: AnyView(SectionProductsView(title: "New Arrivals", subtitle: "Just listed", sort: ""))
                        )
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)

                        // MARK: - Recently Viewed
                        if !recentStore.products.isEmpty {
                            HStack {
                                Text("Recently Viewed").font(.inter(17, weight: .bold)).foregroundStyle(Color.omText)
                                Spacer()
                                Button {
                                    RecentlyViewedStore.shared.clear()
                                } label: {
                                    Text("Clear").font(.inter(13, weight: .semibold)).foregroundStyle(Color.omTextMuted)
                                }
                            }
                            .padding(.horizontal, Spacing.xl)
                            .padding(.bottom, Spacing.m)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.m) {
                                    ForEach(recentStore.products) { product in
                                        NavigationLink { ProductDetailView(product: product) } label: {
                                            recentCard(product)
                                        }
                                        .buttonStyle(PressScaleButtonStyle())
                                    }
                                }
                                .padding(.horizontal, Spacing.xl)
                                .padding(.bottom, Spacing.s)
                            }
                            .padding(.bottom, Spacing.xl)
                        }

                        // MARK: - Recently Added grid
                        HStack {
                            Text("Recently Added").font(.inter(17, weight: .bold)).foregroundStyle(Color.omText)
                            Spacer()
                            NavigationLink("See map") { MapView() }
                                .font(.inter(13, weight: .semibold))
                                .foregroundStyle(Color.omAccent)
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.m)

                        if viewModel.isLoading {
                            SkeletonGrid(count: 6)
                                .padding(.horizontal, Spacing.xl)
                        } else if let err = viewModel.errorMessage {
                            errorState(err)
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

    private func recentCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Rectangle().fill(Color.cream200)
                }
            }
            .frame(width: 120, height: 100)
            .clipped()

            VStack(alignment: .leading, spacing: 3) {
                Text(product.title)
                    .font(.inter(12, weight: .semibold))
                    .foregroundStyle(Color.omText)
                    .lineLimit(1)
                Text(product.price.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                    .font(.inter(12, weight: .bold))
                    .foregroundStyle(Color.omAccent)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .frame(width: 120)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
    }

    @ViewBuilder
    private func sectionCard(title: String, subtitle: String, icon: String, bg: Color, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: Spacing.s) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(subtitle.uppercased())
                        .font(.omMicro)
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                    Text(title)
                        .font(.serif(22))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
                Spacer(minLength: 0)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            }
            .padding(Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "magnifyingglass").font(.system(size: 40)).foregroundStyle(Color.omTextSubtle)
            Text("No listings found").font(.omTitle3).foregroundStyle(Color.omText)
            Text("Try adjusting your filters.").font(.omBody).foregroundStyle(Color.omTextMuted)
        }
        .padding(.top, Spacing.x4)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Spacing.l) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(Color.omTextMuted)
            Text("Couldn't load listings")
                .font(.omTitle3)
                .foregroundStyle(Color.omText)
            Text(message)
                .font(.omBody)
                .foregroundStyle(Color.omTextMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.x4)
            OMButton(label: "Try Again", variant: .secondary, size: .md, icon: "arrow.clockwise") {
                Task { await viewModel.loadProducts() }
            }
        }
        .padding(.top, Spacing.x4)
    }
}

// MARK: - 2-column grid
private struct MasonryGrid: View {
    let products: [Product]
    @State private var appeared = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.m),
        GridItem(.flexible(), spacing: Spacing.m)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.m) {
            ForEach(Array(products.enumerated()), id: \.element.id) { idx, product in
                NavigationLink {
                    ProductDetailView(product: product)
                } label: {
                    ProductCardView(product: product)
                }
                .buttonStyle(PressScaleButtonStyle())
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.8).delay(Double(idx) * 0.04),
                    value: appeared
                )
            }
        }
        .onAppear { appeared = true }
    }
}

private struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
