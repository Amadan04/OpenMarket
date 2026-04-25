import Foundation
import UIKit

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case unauthorized
    case serverError(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "Invalid URL"
        case .noData:              return "No data received"
        case .unauthorized:        return "Session expired. Please log in again."
        case .serverError(let msg): return msg
        case .decodingError:       return "Failed to parse server response"
        }
    }
}

struct ErrorResponse: Decodable {
    let error: String
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    // MARK: - Core request

    @discardableResult
    func request<T: Decodable>(
        _ endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: Constants.baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = KeychainHelper.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            if http.statusCode == 401 {
                await MainActor.run { AppState.shared.sessionExpired = true }
                throw APIError.unauthorized
            }
            if http.statusCode >= 400 {
                let msg = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "Request failed"
                throw APIError.serverError(msg)
            }
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }

    // Multipart image upload — returns the hosted URL string
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let url = URL(string: Constants.baseURL + "/upload") else { throw APIError.invalidURL }
        guard let jpeg = image.jpegData(compressionQuality: 0.8) else { throw APIError.noData }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let token = KeychainHelper.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(jpeg)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse {
            if http.statusCode == 401 {
                await MainActor.run { AppState.shared.sessionExpired = true }
                throw APIError.unauthorized
            }
            if http.statusCode >= 400 {
                let msg = (try? decoder.decode(ErrorResponse.self, from: data))?.error ?? "Upload failed"
                throw APIError.serverError(msg)
            }
        }
        struct UploadResponse: Decodable { let url: String }
        guard let result = try? decoder.decode(UploadResponse.self, from: data) else { throw APIError.decodingError }
        return result.url
    }

    // Void response (e.g. DELETE)
    func requestVoid(
        _ endpoint: String,
        method: String = "DELETE",
        body: Encodable? = nil
    ) async throws {
        guard let url = URL(string: Constants.baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainHelper.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            if http.statusCode == 401 { throw APIError.unauthorized }
            if http.statusCode >= 400 {
                let msg = (try? JSONDecoder().decode(ErrorResponse.self, from: data))?.error ?? "Request failed"
                throw APIError.serverError(msg)
            }
        }
    }
}
