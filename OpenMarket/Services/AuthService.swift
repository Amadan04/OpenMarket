import Foundation

struct AuthResponse: Decodable {
    let token: String
    let user: User
}

struct AuthService {
    static func register(name: String, email: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable { let name, email, password: String }
        return try await APIClient.shared.request(
            Constants.Endpoints.register,
            method: "POST",
            body: Body(name: name, email: email, password: password),
            requiresAuth: false
        )
    }

    static func login(email: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable { let email, password: String }
        return try await APIClient.shared.request(
            Constants.Endpoints.login,
            method: "POST",
            body: Body(email: email, password: password),
            requiresAuth: false
        )
    }

    static func me() async throws -> User {
        return try await APIClient.shared.request(Constants.Endpoints.me)
    }
}
