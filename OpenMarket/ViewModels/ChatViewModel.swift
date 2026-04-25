import Foundation
import Combine

// Envelope sent by the server over the WebSocket.
private struct WSEnvelope: Decodable {
    let type: String
    let data: Message
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    @Published var isConnected = false
    @Published var errorMessage: String?

    private var wsTask: URLSessionWebSocketTask?
    private var currentReceiverID: Int?
    private var reconnectTask: Task<Void, Never>?

    // MARK: - Public API

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
        connectWebSocket()
    }

    func closeChat() {
        reconnectTask?.cancel()
        reconnectTask = nil
        wsTask?.cancel(with: .goingAway, reason: nil)
        wsTask = nil
        currentReceiverID = nil
        messages = []
        isConnected = false
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

    // MARK: - Private

    private func loadMessages(userID: Int) async {
        do {
            messages = try await MessageService.getMessages(withUserID: userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func connectWebSocket() {
        guard let token = KeychainHelper.getToken(),
              var components = URLComponents(string: Constants.wsURL) else { return }

        components.queryItems = [URLQueryItem(name: "token", value: token)]
        guard let url = components.url else { return }

        wsTask?.cancel(with: .goingAway, reason: nil)

        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)
        wsTask = task
        task.resume()
        isConnected = true

        listenForMessages()
    }

    private func listenForMessages() {
        wsTask?.receive { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success(let msg):
                    self.handleWSMessage(msg)
                    self.listenForMessages() // re-arm for next message
                case .failure:
                    self.isConnected = false
                    self.scheduleReconnect()
                }
            }
        }
    }

    private func handleWSMessage(_ msg: URLSessionWebSocketTask.Message) {
        let text: String
        switch msg {
        case .string(let s):  text = s
        case .data(let d):    text = String(data: d, encoding: .utf8) ?? ""
        @unknown default:     return
        }

        guard let data = text.data(using: .utf8) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let envelope = try? decoder.decode(WSEnvelope.self, from: data),
              envelope.type == "message" else { return }

        let incoming = envelope.data
        // Only append if it belongs to the open conversation.
        guard incoming.senderID == currentReceiverID ||
              incoming.receiverID == currentReceiverID else { return }

        // Deduplicate (server-sent messages the local user sent are already appended optimistically).
        guard !messages.contains(where: { $0.id == incoming.id }) else { return }
        messages.append(incoming)

        if incoming.senderID == currentReceiverID {
            NotificationService.shared.scheduleLocalNotification(
                title: "New message",
                body: incoming.content
            )
        }
    }

    private func scheduleReconnect() {
        guard currentReceiverID != nil else { return }
        reconnectTask?.cancel()
        reconnectTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled, currentReceiverID != nil else { return }
            connectWebSocket()
        }
    }
}
