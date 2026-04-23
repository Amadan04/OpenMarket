import SwiftUI

struct SectionProductsView: View {
    let title: String
    let subtitle: String
    let sort: String

    @Environment(\.dismiss) private var dismiss
    @State private var products: [Product] = []
    @State private var isLoading = true

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
                        Text(subtitle.uppercased()).font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text(title).font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                if isLoading {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.m) {
                            ForEach(0..<6, id: \.self) { _ in SkeletonCardView() }
                        }
                        .padding(.horizontal, Spacing.xl)
                    }
                } else if products.isEmpty {
                    Spacer()
                    VStack(spacing: Spacing.m) {
                        Image(systemName: "tag").font(.system(size: 40)).foregroundStyle(Color.omTextSubtle)
                        Text("Nothing here yet").font(.omBodyMed).foregroundStyle(Color.omTextMuted)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.m) {
                            ForEach(products) { product in
                                NavigationLink {
                                    ProductDetailView(product: product)
                                } label: {
                                    ProductCardView(product: product)
                                }
                                .buttonStyle(PressScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        let fetched = (try? await ProductService.getAll(sort: sort, limit: 40)) ?? []
        products = fetched.filter { !$0.isSold } + fetched.filter { $0.isSold }
        isLoading = false
    }
}

private struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
