import Foundation

struct ProductService {
    static func getAll(page: Int = 1, search: String = "") async throws -> [Product] {
        var endpoint = "\(Constants.Endpoints.products)?page=\(page)&limit=20"
        if !search.isEmpty { endpoint += "&search=\(search.urlEncoded)" }
        return try await APIClient.shared.request(endpoint)
    }

    static func getByID(_ id: Int) async throws -> Product {
        return try await APIClient.shared.request("\(Constants.Endpoints.products)/\(id)")
    }

    static func search(category: String = "", minPrice: Double? = nil, maxPrice: Double? = nil, query: String = "") async throws -> [Product] {
        var params: [String] = []
        if !category.isEmpty && category != "All" { params.append("category=\(category.urlEncoded)") }
        if let min = minPrice { params.append("min_price=\(min)") }
        if let max = maxPrice { params.append("max_price=\(max)") }
        if !query.isEmpty { params.append("q=\(query.urlEncoded)") }
        let endpoint = Constants.Endpoints.productSearch + (params.isEmpty ? "" : "?" + params.joined(separator: "&"))
        return try await APIClient.shared.request(endpoint)
    }

    static func nearby(lat: Double, lng: Double, radiusKm: Double = 10) async throws -> [Product] {
        let endpoint = "\(Constants.Endpoints.productNearby)?lat=\(lat)&lng=\(lng)&radius_km=\(radiusKm)"
        return try await APIClient.shared.request(endpoint)
    }

    static func getByUser(userID: Int) async throws -> [Product] {
        return try await APIClient.shared.request("\(Constants.Endpoints.products)?user_id=\(userID)&limit=100")
    }

    static func create(_ body: CreateProductRequest) async throws -> Product {
        return try await APIClient.shared.request(Constants.Endpoints.products, method: "POST", body: body)
    }

    static func update(id: Int, body: CreateProductRequest) async throws -> Product {
        return try await APIClient.shared.request("\(Constants.Endpoints.products)/\(id)", method: "PUT", body: body)
    }

    static func delete(id: Int) async throws {
        try await APIClient.shared.requestVoid("\(Constants.Endpoints.products)/\(id)")
    }
}

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
