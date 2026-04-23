import Foundation
import Combine

@MainActor
final class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Filter state
    @Published var searchText = ""
    @Published var selectedCategory = "All"
    @Published var selectedCondition = "Any"
    @Published var minPrice: Double?
    @Published var maxPrice: Double?
    @Published var radiusKm: Double? = nil

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fetched = try await ProductService.getAll(search: searchText)
            products = fetched.filter { !$0.isSold } + fetched.filter { $0.isSold }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func applyFilters() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let fetched: [Product]
            if let radius = radiusKm,
               let loc = LocationService.shared.currentLocation {
                fetched = try await ProductService.nearby(
                    lat: loc.coordinate.latitude,
                    lng: loc.coordinate.longitude,
                    radiusKm: radius
                )
            } else {
                fetched = try await ProductService.search(
                    category: selectedCategory,
                    condition: selectedCondition,
                    minPrice: minPrice,
                    maxPrice: maxPrice,
                    query: searchText
                )
            }
            products = fetched.filter { !$0.isSold } + fetched.filter { $0.isSold }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetFilters() {
        selectedCategory = "All"
        selectedCondition = "Any"
        minPrice = nil
        maxPrice = nil
        radiusKm = nil
        searchText = ""
    }
}
