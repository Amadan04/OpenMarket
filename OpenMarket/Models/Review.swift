import Foundation

struct Review: Codable, Identifiable {
    let id: Int
    let rating: Int
    let comment: String
    let sellerID: Int
    let reviewerID: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, rating, comment
        case sellerID   = "seller_id"
        case reviewerID = "reviewer_id"
        case createdAt  = "created_at"
    }
}

struct ReviewsResponse: Decodable {
    let sellerID: Int
    let averageRating: Double
    let reviewsCount: Int
    let reviews: [Review]

    enum CodingKeys: String, CodingKey {
        case reviews
        case sellerID      = "seller_id"
        case averageRating = "average_rating"
        case reviewsCount  = "reviews_count"
    }
}

struct CreateReviewRequest: Encodable {
    let sellerID: Int
    let rating: Int
    let comment: String

    enum CodingKeys: String, CodingKey {
        case sellerID = "seller_id"
        case rating, comment
    }
}
