import Foundation
import Combine

@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published var product: Product
    @Published var reviews: ReviewsResponse?
    @Published var isFavorited = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(product: Product) {
        self.product = product
    }

    func loadReviews() async {
        do {
            reviews = try await ReviewService.getReviews(forSellerID: product.userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite() async {
        do {
            if isFavorited {
                try await FavoriteService.remove(productID: product.id)
            } else {
                try await FavoriteService.add(productID: product.id)
            }
            isFavorited.toggle()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
