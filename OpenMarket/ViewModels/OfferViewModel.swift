import Foundation

@MainActor
final class OfferViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var isLoading = false
    @Published var respondingID: Int? = nil
    @Published var errorMessage: String? = nil

    func loadOffers(forListingID id: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            offers = try await OfferService.getOffers(forListingID: id)
        } catch {
            errorMessage = "Failed to load offers."
        }
    }

    func respond(offerID: Int, action: String, counterAmount: Double? = nil) async {
        respondingID = offerID
        defer { respondingID = nil }
        do {
            let updated = try await OfferService.respond(offerID: offerID, action: action, counterAmount: counterAmount)
            if let idx = offers.firstIndex(where: { $0.id == offerID }) {
                offers[idx] = updated
            }
        } catch {
            errorMessage = "Failed to update offer."
        }
    }

    var pendingCount: Int {
        offers.filter { $0.status == .pending }.count
    }
}
