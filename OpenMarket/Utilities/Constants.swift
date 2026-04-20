import Foundation

enum Constants {
    static let baseURL = "http://localhost:8080"

    enum Endpoints {
        static let register       = "/auth/register"
        static let login          = "/auth/login"
        static let me             = "/auth/me"

        static let products       = "/products"
        static let productSearch  = "/products/search"
        static let productNearby  = "/products/nearby"

        static let favorites      = "/favorites"

        static let messages       = "/messages"
        static let conversations  = "/conversations"

        static let reviews        = "/reviews"
        static let upload         = "/upload"
    }

    enum Categories {
        static let all: [String] = [
            "All", "Vehicles", "Property", "Mobile",
            "Electronics", "Furniture", "Fashion",
            "Sports", "Books", "Other"
        ]
    }
}
