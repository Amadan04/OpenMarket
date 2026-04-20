import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var selectedFilter = "All (0)"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.omBg.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Text("Saved")
                            .font(.serif(34))
                            .foregroundStyle(Color.omText)
                        Spacer()
                        Button("Edit") {}
                            .font(.inter(13, weight: .semibold))
                            .foregroundStyle(Color.omAccent)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.l)
                    .padding(.bottom, Spacing.m)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.s) {
                            let count = viewModel.favorites.count
                            ForEach(["All (\(count))", "Available", "Sold"], id: \.self) { f in
                                OMChip(label: f, active: selectedFilter == f || (f.hasPrefix("All") && selectedFilter.hasPrefix("All")))
                                    .onTapGesture { selectedFilter = f }
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                    }
                    .padding(.bottom, Spacing.m)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if viewModel.favorites.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Spacing.m) {
                                ForEach(viewModel.favorites) { fav in
                                    NavigationLink { ProductDetailView(product: fav.product) } label: {
                                        HStack(spacing: Spacing.m) {
                                            AsyncImage(url: URL(string: fav.product.images.first ?? "")) { phase in
                                                switch phase {
                                                case .success(let img): img.resizable().scaledToFill()
                                                default: Rectangle().fill(Color.cream200)
                                                }
                                            }
                                            .frame(width: 86, height: 86)
                                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(fav.product.title)
                                                    .font(.inter(15, weight: .semibold))
                                                    .foregroundStyle(Color.omText)
                                                    .lineLimit(2)
                                                Text(fav.product.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                                                    .font(.inter(16, weight: .bold))
                                                    .foregroundStyle(Color.omAccent)
                                                HStack(spacing: 3) {
                                                    Image(systemName: "mappin").font(.system(size: 10)).foregroundStyle(Color.omTextSubtle)
                                                    Text(fav.product.location).font(.inter(12)).foregroundStyle(Color.omTextMuted)
                                                }
                                            }
                                            Spacer()

                                            Button {
                                                Task { await viewModel.remove(productID: fav.product.id) }
                                            } label: {
                                                Image(systemName: "heart.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundStyle(Color.omAccent)
                                                    .frame(width: 32, height: 32)
                                            }
                                        }
                                        .padding(Spacing.m)
                                        .background(Color.omBgElevated)
                                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                                        .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, Spacing.xl)
                            .padding(.bottom, Spacing.xl)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task { await viewModel.load() }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Image(systemName: "heart").font(.system(size: 48)).foregroundStyle(Color.omTextSubtle)
            Text("Nothing saved yet").font(.omTitle3).foregroundStyle(Color.omText)
            Text("Tap the heart on any listing to save it here.")
                .font(.omBody).foregroundStyle(Color.omTextMuted).multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, Spacing.x4)
    }
}
