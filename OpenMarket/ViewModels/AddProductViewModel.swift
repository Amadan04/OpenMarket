import Foundation
import SwiftUI
import Combine

@MainActor
final class AddProductViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var price = ""
    @Published var category = "Other"
    @Published var condition = "Good"
    @Published var location = ""
    @Published var images: [UIImage] = []
    @Published var imageURLs: [String] = []
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSubmit = false
    @Published var draftSaved = false

    private let draftKey = "add_product_draft_v1"

    init() { loadDraft() }

    var isValid: Bool {
        !title.isEmpty && !price.isEmpty && Double(price) != nil
    }

    func uploadImages() async throws {
        for image in images {
            let url = try await APIClient.shared.uploadImage(image)
            imageURLs.append(url)
        }
    }

    func submit() async {
        guard isValid else {
            errorMessage = "Please fill in all required fields."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            if !images.isEmpty && imageURLs.count < images.count {
                try await uploadImages()
            }
            let body = CreateProductRequest(
                title: title,
                description: description,
                price: Double(price) ?? 0,
                category: category,
                condition: condition,
                location: location,
                images: imageURLs,
                latitude: latitude,
                longitude: longitude
            )
            _ = try await ProductService.create(body)
            didSubmit = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveDraft() {
        let draft: [String: Any] = [
            "title": title, "description": description, "price": price,
            "category": category, "condition": condition, "location": location,
            "latitude": latitude, "longitude": longitude
        ]
        UserDefaults.standard.set(draft, forKey: draftKey)
        draftSaved = true
        Task { try? await Task.sleep(nanoseconds: 2_000_000_000); draftSaved = false }
    }

    func reset() {
        title = ""; description = ""; price = ""; category = "Other"
        condition = "Good"; location = ""; images = []; imageURLs = []
        latitude = 0; longitude = 0; didSubmit = false; errorMessage = nil
        UserDefaults.standard.removeObject(forKey: draftKey)
    }

    private func loadDraft() {
        guard let draft = UserDefaults.standard.dictionary(forKey: draftKey) else { return }
        title       = draft["title"]       as? String ?? ""
        description = draft["description"] as? String ?? ""
        price       = draft["price"]       as? String ?? ""
        category    = draft["category"]    as? String ?? "Other"
        condition   = draft["condition"]   as? String ?? "Good"
        location    = draft["location"]    as? String ?? ""
        latitude    = draft["latitude"]    as? Double ?? 0
        longitude   = draft["longitude"]  as? Double ?? 0
    }
}
