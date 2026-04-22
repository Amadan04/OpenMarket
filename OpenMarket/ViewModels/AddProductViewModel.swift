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

    func reset() {
        title = ""; description = ""; price = ""; category = "Other"
        location = ""; images = []; imageURLs = []; latitude = 0; longitude = 0
        didSubmit = false; errorMessage = nil
    }
}
