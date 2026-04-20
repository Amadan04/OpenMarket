import Foundation

struct MessageService {
    static func getConversations() async throws -> [Conversation] {
        return try await APIClient.shared.request(Constants.Endpoints.conversations)
    }

    static func getMessages(withUserID userID: Int) async throws -> [Message] {
        return try await APIClient.shared.request("\(Constants.Endpoints.conversations)/\(userID)/messages")
    }

    static func send(to receiverID: Int, content: String) async throws -> Message {
        return try await APIClient.shared.request(
            Constants.Endpoints.messages,
            method: "POST",
            body: SendMessageRequest(receiverID: receiverID, content: content)
        )
    }

    static func delete(messageID: Int) async throws {
        try await APIClient.shared.requestVoid("\(Constants.Endpoints.messages)/\(messageID)")
    }
}
