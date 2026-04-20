import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var myListings: [Product] = []
    @Published var myReviews: ReviewsResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadMyListings(userID: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            // Will use ?user_id= filter once backend supports it
            let all = try await ProductService.getAll()
            myListings = all.filter { $0.userID == userID }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMyReviews(userID: Int) async {
        do {
            myReviews = try await ReviewService.getReviews(forSellerID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteProduct(id: Int) async {
        do {
            try await ProductService.delete(id: id)
            myListings.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
