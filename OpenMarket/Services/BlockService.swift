import Foundation

struct BlockedUser: Decodable {
    let id: Int
    let blockerID: Int
    let blockedID: Int

    enum CodingKeys: String, CodingKey {
        case id
        case blockerID = "blocker_id"
        case blockedID = "blocked_id"
    }
}

struct BlockService {
    static func block(userID: Int) async throws {
        try await APIClient.shared.requestVoid("/users/\(userID)/block", method: "POST")
    }

    static func unblock(userID: Int) async throws {
        try await APIClient.shared.requestVoid("/users/\(userID)/block", method: "DELETE")
    }

    static func getBlocked() async throws -> [BlockedUser] {
        return try await APIClient.shared.request(Constants.Endpoints.blocks)
    }

    static func isBlocked(userID: Int) async -> Bool {
        guard let blocked = try? await getBlocked() else { return false }
        return blocked.contains { $0.blockedID == userID }
    }
}
