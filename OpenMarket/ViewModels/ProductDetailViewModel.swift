import Foundation
import Combine

@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published var product: Product
    @Published var reviews: ReviewsResponse?
    @Published var isFavorited = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var myOffer: Offer? = nil
    @Published var isWithdrawingOffer = false

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

    func loadMyOffer() async {
        do {
            let offers = try await OfferService.getMyOffers()
            myOffer = offers.first { $0.listingID == product.id && $0.status != .withdrawn }
        } catch {}
    }

    func withdrawOffer() async {
        guard let offer = myOffer else { return }
        isWithdrawingOffer = true
        defer { isWithdrawingOffer = false }
        do {
            try await OfferService.withdraw(offerID: offer.id)
            myOffer = nil
        } catch {
            errorMessage = "Failed to withdraw offer."
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
