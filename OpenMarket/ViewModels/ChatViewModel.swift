import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var pollingTask: Task<Void, Never>?
    private var currentReceiverID: Int?

    func loadConversations() async {
        isLoading = true
        defer { isLoading = false }
        do {
            conversations = try await MessageService.getConversations()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openChat(with userID: Int) async {
        currentReceiverID = userID
        await loadMessages(userID: userID)
        startPolling(userID: userID)
    }

    func closeChat() {
        pollingTask?.cancel()
        pollingTask = nil
        currentReceiverID = nil
        messages = []
    }

    func sendMessage(content: String) async {
        guard let receiverID = currentReceiverID else { return }
        do {
            let msg = try await MessageService.send(to: receiverID, content: content)
            messages.append(msg)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadMessages(userID: Int) async {
        do {
            messages = try await MessageService.getMessages(withUserID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startPolling(userID: Int) {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5s
                guard !Task.isCancelled else { break }
                let prevCount = messages.count
                await loadMessages(userID: userID)
                let newCount = messages.count
                if newCount > prevCount {
                    let latest = messages.last
                    NotificationService.shared.scheduleLocalNotification(
                        title: "New message",
                        body: latest?.content ?? "You have a new message"
                    )
                }
            }
        }
    }
}
