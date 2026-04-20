import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        // TODO: Replace with design handoff
        Text("RegisterView — placeholder")
    }
}
