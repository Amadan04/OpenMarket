import Foundation

struct Message: Codable, Identifiable {
    let id: Int
    let senderID: Int
    let receiverID: Int
    let content: String
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id, content, timestamp
        case senderID   = "sender_id"
        case receiverID = "receiver_id"
    }
}

struct SendMessageRequest: Encodable {
    let receiverID: Int
    let content: String

    enum CodingKeys: String, CodingKey {
        case receiverID = "receiver_id"
        case content
    }
}
