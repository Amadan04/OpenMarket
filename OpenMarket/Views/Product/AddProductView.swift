import SwiftUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        // TODO: Replace with design handoff
        Text("AddProductView — placeholder")
    }
}
