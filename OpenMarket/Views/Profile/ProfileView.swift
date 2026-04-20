import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        // TODO: Replace with design handoff
        Text("ProfileView — placeholder")
    }
}
