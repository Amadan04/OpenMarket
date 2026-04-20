import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    let otherUser: User
    @State private var messageText = ""

    var body: some View {
        // TODO: Replace with design handoff
        Text("ChatView — placeholder")
    }
}
