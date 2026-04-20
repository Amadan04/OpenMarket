import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favorites: [Favorite] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            favorites = try await FavoriteService.getFavorites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func remove(productID: Int) async {
        do {
            try await FavoriteService.remove(productID: productID)
            favorites.removeAll { $0.product.id == productID }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
