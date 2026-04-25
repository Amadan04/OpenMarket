import Foundation

enum OfferStatus: String, Codable {
    case pending, accepted, declined, countered, withdrawn
}

struct Offer: Codable, Identifiable {
    let id: Int
    let listingID: Int
    let buyerID: Int
    let sellerID: Int
    let amount: Double
    let note: String
    let status: OfferStatus
    let counterAmount: Double?
    let buyerName: String?
    let listingTitle: String?
    let sellerName: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, amount, note, status
        case listingID     = "listing_id"
        case buyerID       = "buyer_id"
        case sellerID      = "seller_id"
        case counterAmount = "counter_amount"
        case buyerName     = "buyer_name"
        case listingTitle  = "listing_title"
        case sellerName    = "seller_name"
        case createdAt     = "created_at"
        case updatedAt     = "updated_at"
    }
}

struct CreateOfferRequest: Encodable {
    let listingID: Int
    let amount: Double
    let note: String

    enum CodingKeys: String, CodingKey {
        case listingID = "listing_id"
        case amount, note
    }
}

struct RespondToOfferRequest: Encodable {
    let action: String
    let counterAmount: Double?

    enum CodingKeys: String, CodingKey {
        case action
        case counterAmount = "counter_amount"
    }
}
