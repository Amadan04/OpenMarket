import SwiftUI

// Grid card (2-column masonry style)
struct ProductCardView: View {
    let product: Product
    var isFavorited: Bool = false
    var onFavorite: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable()
                            .scaledToFill()
                            .frame(height: 130)
                            .clipped()
                    default:
                        Rectangle()
                            .fill(Color.cream200)
                            .frame(height: 130)
                            .overlay(Image(systemName: "photo").font(.title2).foregroundStyle(Color.stone300))
                    }
                }
                .frame(height: 130)

                Button {
                    onFavorite?()
                } label: {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isFavorited ? Color.omAccent : Color.omText)
                        .frame(width: 32, height: 32)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
                .padding(Spacing.s)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(product.title)
                    .font(.inter(13, weight: .semibold))
                    .foregroundStyle(Color.omText)
                    .lineLimit(2)
                    .frame(height: 36, alignment: .topLeading)

                Text(product.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                    .font(.inter(14, weight: .bold))
                    .foregroundStyle(Color.omAccent)

                HStack(spacing: 3) {
                    Image(systemName: "mappin")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.omTextSubtle)
                    Text(product.location.isEmpty ? "No location" : product.location)
                        .font(.inter(11))
                        .foregroundStyle(Color.omTextMuted)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.s)
        }
        .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 220, alignment: .topLeading)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
    }
}

// Row card (list style — used in Favorites, My Listings)
struct ProductRowCard: View {
    let product: Product
    var badge: String? = nil
    var badgeColor: Color = .omOk

    var body: some View {
        HStack(spacing: Spacing.m) {
            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Rectangle().fill(Color.cream200)
                        .overlay(Image(systemName: "photo").foregroundStyle(Color.stone300))
                }
            }
            .frame(width: 86, height: 86)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.inter(15, weight: .semibold))
                    .foregroundStyle(Color.omText)
                    .lineLimit(2)

                Text(product.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                    .font(.inter(16, weight: .bold))
                    .foregroundStyle(Color.omAccent)

                HStack(spacing: 3) {
                    Image(systemName: "mappin").font(.system(size: 10)).foregroundStyle(Color.omTextSubtle)
                    Text(product.location).font(.inter(12)).foregroundStyle(Color.omTextMuted)
                }

                if let badge {
                    Text(badge)
                        .font(.inter(11, weight: .semibold))
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(badgeColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(Spacing.m)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
    }
}
