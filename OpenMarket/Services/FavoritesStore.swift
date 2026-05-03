import Foundation

final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()

    @Published private(set) var favoritedIDs: Set<Int> = []

    private init() {
        Task { await refresh() }
    }

    func isFavorited(_ productID: Int) -> Bool {
        favoritedIDs.contains(productID)
    }

    func toggle(_ productID: Int) {
        if favoritedIDs.contains(productID) {
            favoritedIDs.remove(productID)
            Task { try? await FavoriteService.remove(productID: productID) }
        } else {
            favoritedIDs.insert(productID)
            Task { try? await FavoriteService.add(productID: productID) }
        }
    }

    func refresh() async {
        let favorites = (try? await FavoriteService.getFavorites()) ?? []
        let ids = Set(favorites.map { $0.product.id })
        await MainActor.run { favoritedIDs = ids }
    }
}
