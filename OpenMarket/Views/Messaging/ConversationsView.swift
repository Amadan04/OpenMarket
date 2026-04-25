import SwiftUI

struct ConversationsView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    private let filters = ["All", "Buying", "Selling", "Unread"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.omBg.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Title
                    Text("Messages")
                        .font(.serif(34))
                        .foregroundStyle(Color.omText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.l)
                        .padding(.bottom, Spacing.m)

                    // Search bar
                    HStack(spacing: Spacing.m) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Color.omTextMuted)
                        TextField("Search messages", text: $searchText)
                            .font(.inter(14))
                            .foregroundStyle(Color.omText)
                    }
                    .padding(.horizontal, Spacing.l)
                    .frame(height: 42)
                    .background(Color.omBgElevated)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.omBorder, lineWidth: 1))
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.m)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.s) {
                            ForEach(filters, id: \.self) { f in
                                OMChip(label: f, active: selectedFilter == f)
                                    .onTapGesture { selectedFilter = f }
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                    }
                    .padding(.bottom, Spacing.s)

                    Divider()

                    if viewModel.isLoading {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(0..<6, id: \.self) { _ in
                                    SkeletonConversationRow()
                                    Divider().padding(.leading, Spacing.xl + 52 + Spacing.m)
                                }
                            }
                        }
                    } else if viewModel.conversations.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(filteredConversations) { conversation in
                                    NavigationLink {
                                        ChatView(viewModel: viewModel, otherUser: conversation.participant)
                                            .task { await viewModel.openChat(with: conversation.participant.id) }
                                    } label: {
                                        conversationRow(conversation)
                                    }
                                    .buttonStyle(.plain)
                                    Divider().padding(.leading, 76)
                                }
                            }
                            .padding(.horizontal, Spacing.s)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .task { await viewModel.loadConversations() }
        }
    }

    private var filteredConversations: [Conversation] {
        viewModel.conversations.filter { conv in
            if searchText.isEmpty { return true }
            return conv.participant.name.localizedCaseInsensitiveContains(searchText)
                || conv.lastMessage.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func conversationRow(_ conv: Conversation) -> some View {
        HStack(spacing: Spacing.m) {
            AvatarView(initial: conv.participant.name.prefix(1).description, size: 52, tone: .clay)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(conv.participant.name)
                        .font(.inter(15, weight: .semibold))
                        .foregroundStyle(Color.omText)
                    Spacer()
                    Text(conv.lastMessage.timestamp, style: .relative)
                        .font(.inter(12))
                        .foregroundStyle(Color.omAccent)
                }
                Text(conv.lastMessage.content)
                    .font(.inter(13, weight: .medium))
                    .foregroundStyle(Color.omText)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.m)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 48)).foregroundStyle(Color.omTextSubtle)
            Text("No messages yet").font(.omTitle3).foregroundStyle(Color.omText)
            Text("Start a conversation by messaging a seller.")
                .font(.omBody).foregroundStyle(Color.omTextMuted).multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, Spacing.x4)
    }
}
