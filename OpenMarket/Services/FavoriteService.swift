import Foundation

struct FavoriteService {
    static func getFavorites() async throws -> [Favorite] {
        return try await APIClient.shared.request(Constants.Endpoints.favorites)
    }

    static func add(productID: Int) async throws {
        try await APIClient.shared.requestVoid("\(Constants.Endpoints.favorites)/\(productID)", method: "POST")
    }

    static func remove(productID: Int) async throws {
        try await APIClient.shared.requestVoid("\(Constants.Endpoints.favorites)/\(productID)")
    }
}
