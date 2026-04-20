import Foundation

struct Conversation: Identifiable, Decodable {
    let id: Int           // = participant's userID
    let participant: User
    let lastMessage: Message

    enum CodingKeys: String, CodingKey {
        case id
        case participant
        case lastMessage = "last_message"
    }
}
