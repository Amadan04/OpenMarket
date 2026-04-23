import Foundation

struct OfferService {
    static func create(listingID: Int, amount: Double, note: String) async throws -> Offer {
        return try await APIClient.shared.request(
            Constants.Endpoints.offers,
            method: "POST",
            body: CreateOfferRequest(listingID: listingID, amount: amount, note: note)
        )
    }

    static func getMyOffers() async throws -> [Offer] {
        return try await APIClient.shared.request("\(Constants.Endpoints.offers)/my")
    }

    static func getOffers(forListingID id: Int) async throws -> [Offer] {
        return try await APIClient.shared.request("/products/\(id)/offers")
    }

    static func respond(offerID: Int, action: String, counterAmount: Double? = nil) async throws -> Offer {
        return try await APIClient.shared.request(
            "\(Constants.Endpoints.offers)/\(offerID)",
            method: "PATCH",
            body: RespondToOfferRequest(action: action, counterAmount: counterAmount)
        )
    }

    static func withdraw(offerID: Int) async throws {
        try await APIClient.shared.requestVoid(
            "\(Constants.Endpoints.offers)/\(offerID)",
            method: "DELETE"
        )
    }
}
