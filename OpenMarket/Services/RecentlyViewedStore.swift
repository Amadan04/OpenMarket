import Foundation
import Combine

final class RecentlyViewedStore: ObservableObject {
    static let shared = RecentlyViewedStore()

    @Published private(set) var products: [Product] = []

    private let key = "recently_viewed_v1"
    private let limit = 10

    private init() { load() }

    func record(_ product: Product) {
        var updated = products.filter { $0.id != product.id }
        updated.insert(product, at: 0)
        products = Array(updated.prefix(limit))
        save()
    }

    func clear() {
        products = []
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(products) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        products = (try? decoder.decode([Product].self, from: data)) ?? []
    }
}
