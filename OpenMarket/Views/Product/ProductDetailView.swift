import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    init(product: Product) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }

    var body: some View {
        // TODO: Replace with design handoff
        Text(viewModel.product.title)
    }
}
