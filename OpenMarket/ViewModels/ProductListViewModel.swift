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

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            products = try await ProductService.getAll(search: searchText)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func applyFilters() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            products = try await ProductService.search(
                category: selectedCategory,
                condition: selectedCondition,
                minPrice: minPrice,
                maxPrice: maxPrice,
                query: searchText
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetFilters() {
        selectedCategory = "All"
        selectedCondition = "Any"
        minPrice = nil
        maxPrice = nil
        searchText = ""
    }
}
