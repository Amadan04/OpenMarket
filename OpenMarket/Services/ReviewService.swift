import Foundation

struct ReviewService {
    static func getReviews(forSellerID sellerID: Int) async throws -> ReviewsResponse {
        return try await APIClient.shared.request("/users/\(sellerID)/reviews")
    }

    static func addReview(sellerID: Int, rating: Int, comment: String) async throws -> Review {
        return try await APIClient.shared.request(
            Constants.Endpoints.reviews,
            method: "POST",
            body: CreateReviewRequest(sellerID: sellerID, rating: rating, comment: comment)
        )
    }

    static func delete(reviewID: Int) async throws {
        try await APIClient.shared.requestVoid("\(Constants.Endpoints.reviews)/\(reviewID)")
    }
}
