import Foundation

struct Product: Codable, Identifiable {
    let id: Int
    var title: String
    var description: String
    var price: Double
    var category: String
    var location: String
    var images: [String]
    var latitude: Double
    var longitude: Double
    var condition: String
    var viewCount: Int
    var isSold: Bool
    let userID: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, category, location, images, latitude, longitude
        case condition
        case viewCount = "view_count"
        case isSold    = "is_sold"
        case userID    = "user_id"
        case createdAt = "created_at"
    }
}

struct CreateProductRequest: Encodable {
    let title: String
    let description: String
    let price: Double
    let category: String
    let condition: String
    let location: String
    let images: [String]
    let latitude: Double
    let longitude: Double
}
