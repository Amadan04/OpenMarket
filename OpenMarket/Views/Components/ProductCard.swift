import SwiftUI

struct ProductCardView: View {
    let product: Product
    var isFavorited: Bool = false
    var onFavorite: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image — fixed height, fills column width via parent grid cell
            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Color(uiColor: UIColor(Color.cream200))
                        .overlay(Image(systemName: "photo").font(.system(size: 24)).foregroundStyle(Color.stone300))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130)
            .clipped()
            .overlay(alignment: .topTrailing) {
                Button { onFavorite?() } label: {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isFavorited ? Color.omAccent : Color.omText)
                        .frame(width: 28, height: 28)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
                .padding(6)
                .buttonStyle(.plain)
            }
            .overlay {
                if product.isSold {
                    ZStack {
                        Color.black.opacity(0.45)
                        Text("SOLD")
                            .font(.inter(13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }

            // Text — fixed height so all cards are uniform
            VStack(alignment: .leading, spacing: 2) {
                Text(product.title)
                    .font(.inter(12, weight: .semibold))
                    .foregroundStyle(Color.omText)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .topLeading)

                Text(product.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                    .font(.inter(13, weight: .bold))
                    .foregroundStyle(Color.omAccent)

                Text(product.location.isEmpty ? "No location" : product.location)
                    .font(.inter(10))
                    .foregroundStyle(Color.omTextMuted)
                    .lineLimit(1)
            }
            .padding(8)
            .frame(height: 76, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity)
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
