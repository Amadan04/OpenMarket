import Foundation

struct Favorite: Codable, Identifiable {
    let id: Int
    let userID: Int
    let product: Product

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case product
    }
}
