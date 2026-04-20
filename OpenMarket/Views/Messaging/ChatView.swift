import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    let otherUser: User
    @State private var messageText = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var composerFocused: Bool

    private let quickReplies = ["👍 Sounds good", "💰 Make offer", "📍 Share location"]

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                pinnedProduct
                messageList
                composer
            }
        }
        .navigationBarHidden(true)
        .onDisappear { viewModel.closeChat() }
    }

    // MARK: - Nav bar
    private var navBar: some View {
        HStack(spacing: Spacing.m) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.omText)
                    .frame(width: 36, height: 36)
                    .background(Color.omBgElevated)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
            }

            AvatarView(initial: otherUser.name.prefix(1).description, size: 36, tone: .sage)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(otherUser.name).font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText)
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 12)).foregroundStyle(Color.sage500)
                }
                Text("● Active now").font(.inter(11, weight: .medium)).foregroundStyle(Color.sage500)
            }
            Spacer()
            Image(systemName: "ellipsis").font(.system(size: 18)).foregroundStyle(Color.omTextMuted)
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.m)
        .background(Color.omBg)
        .overlay(alignment: .bottom) { Color.omBorder.frame(height: 0.5) }
    }

    // MARK: - Pinned product (placeholder)
    private var pinnedProduct: some View {
        HStack(spacing: Spacing.m) {
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(Color.cream200)
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "photo").foregroundStyle(Color.stone300))

            VStack(alignment: .leading, spacing: 2) {
                Text("Listing").font(.inter(13, weight: .semibold)).foregroundStyle(Color.omText).lineLimit(1)
                Text("View item").font(.inter(13, weight: .bold)).foregroundStyle(Color.omAccent)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13)).foregroundStyle(Color.omTextMuted)
        }
        .padding(Spacing.m)
        .background(Color.omBgElevated)
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(Color.omBgSunken)
    }

    // MARK: - Message list
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: Spacing.s) {
                    Text("Today")
                        .font(.omMicro)
                        .foregroundStyle(Color.omTextMuted)
                        .padding(.vertical, Spacing.s)

                    ForEach(viewModel.messages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }

                    if viewModel.messages.isEmpty {
                        Text("Say hello!")
                            .font(.omBody)
                            .foregroundStyle(Color.omTextMuted)
                            .padding(.top, Spacing.x4)
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let last = viewModel.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    @ViewBuilder
    private func messageBubble(_ message: Message) -> some View {
        let isMe = message.senderID == KeychainHelper.getUserID()
        HStack(alignment: .bottom, spacing: Spacing.s) {
            if isMe { Spacer(minLength: 60) }
            if !isMe { AvatarView(initial: otherUser.name.prefix(1).description, size: 28, tone: .sage) }

            Text(message.content)
                .font(.inter(14.5))
                .foregroundStyle(isMe ? .white : Color.omText)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.m)
                .background(isMe ? Color.omAccent : Color.omBgElevated)
                .clipShape(
                    .rect(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: isMe ? 18 : 4,
                        bottomTrailingRadius: isMe ? 4 : 18,
                        topTrailingRadius: 18
                    )
                )
                .overlay(
                    isMe ? nil :
                    RoundedRectangle(cornerRadius: 18).stroke(Color.omBorder, lineWidth: 1)
                )
                .frame(maxWidth: 280, alignment: isMe ? .trailing : .leading)

            if isMe { AvatarView(initial: "M", size: 28) }
            if !isMe { Spacer(minLength: 60) }
        }
    }

    // MARK: - Composer
    private var composer: some View {
        VStack(spacing: Spacing.s) {
            // Quick replies
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s) {
                    ForEach(quickReplies, id: \.self) { reply in
                        OMChip(label: reply)
                            .onTapGesture { messageText = reply }
                    }
                }
                .padding(.horizontal, Spacing.m)
            }

            HStack(spacing: Spacing.s) {
                HStack(spacing: Spacing.s) {
                    TextField("Message…", text: $messageText, axis: .vertical)
                        .font(.omCallout)
                        .foregroundStyle(Color.omText)
                        .focused($composerFocused)
                        .lineLimit(1...5)
                    Image(systemName: "camera")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.omTextMuted)
                        .frame(width: 36, height: 36)
                        .background(Color.omBgSunken)
                        .clipShape(Circle())
                }
                .padding(.leading, Spacing.l)
                .padding(.trailing, Spacing.s)
                .padding(.vertical, Spacing.s)
                .background(Color.omBgElevated)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.omBorder, lineWidth: 1))

                Button {
                    let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    messageText = ""
                    Task { await viewModel.sendMessage(content: text) }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.omAccent)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, Spacing.m)
        }
        .padding(.bottom, Spacing.l)
        .background(Color.omBg)
        .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
    }
}
