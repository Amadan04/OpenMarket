import SwiftUI

struct SoldConfirmationSheet: View {
    let product: Product
    var onSold: ((Product) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var conversations: [Conversation] = []
    @State private var isLoading = true
    @State private var selectedBuyerID: Int? = nil
    @State private var isMarking = false
    @State private var showReviewPrompt = false
    @State private var soldProduct: Product? = nil

    var body: some View {
        VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5)
                    .padding(.top, Spacing.m)

                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 32, height: 32)
                            .background(Color.omBgSunken)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Mark as Sold")
                        .font(.inter(16, weight: .bold))
                        .foregroundStyle(Color.omText)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)
                .padding(.bottom, Spacing.s)

                // Product row
                HStack(spacing: Spacing.m) {
                    AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color.cream200
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.title)
                            .font(.inter(14, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .lineLimit(1)
                        Text(product.price.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                            .font(.inter(13, weight: .bold))
                            .foregroundStyle(Color.omAccent)
                    }
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.l)

                Divider()

                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("WHO DID YOU SELL TO?")
                        .font(.omMicro)
                        .foregroundStyle(Color.omTextSubtle)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.l)

                    if isLoading {
                        HStack { Spacer(); ProgressView(); Spacer() }
                            .padding(.vertical, Spacing.xl)
                    } else if conversations.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: Spacing.s) {
                                Image(systemName: "bubble.left").font(.system(size: 28)).foregroundStyle(Color.omTextSubtle)
                                Text("No conversations found")
                                    .font(.inter(13)).foregroundStyle(Color.omTextMuted)
                            }
                            Spacer()
                        }
                        .padding(.vertical, Spacing.xl)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                // Skip option
                                buyerRow(
                                    id: nil,
                                    name: "Skip — sold elsewhere",
                                    subtitle: "Don't link a buyer",
                                    icon: "person.slash"
                                )
                                Divider().padding(.leading, 72)

                                ForEach(conversations) { conv in
                                    buyerRow(
                                        id: conv.participant.id,
                                        name: conv.participant.name,
                                        subtitle: conv.lastMessage.content,
                                        icon: nil,
                                        initial: conv.participant.name.prefix(1).description
                                    )
                                    Divider().padding(.leading, 72)
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                }

                Spacer()

                // CTA
                OMButton(
                    label: selectedBuyerID == nil && !conversations.isEmpty
                        ? "Mark as Sold (no buyer)"
                        : "Mark as Sold",
                    size: .lg,
                    fullWidth: true,
                    icon: "checkmark.circle.fill",
                    isLoading: isMarking
                ) {
                    Task { await markSold() }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .background(Color.omBg)
                .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
        }
        .presentationBackground(Color.omBg)
        .presentationDetents([.large])
        .task { await loadConversations() }
        .sheet(isPresented: $showReviewPrompt) {
            if let p = soldProduct, let buyerID = p.buyerID {
                reviewPrompt(buyerID: buyerID, product: p)
            }
        }
    }

    // MARK: - Row

    @ViewBuilder
    private func buyerRow(id: Int?, name: String, subtitle: String, icon: String?, initial: String? = nil) -> some View {
        let isSelected = selectedBuyerID == id && !(id == nil && selectedBuyerID != nil)
        let actuallySelected: Bool = {
            if id == nil { return selectedBuyerID == nil }
            return selectedBuyerID == id
        }()

        Button {
            withAnimation(.spring(response: 0.25)) {
                selectedBuyerID = id
            }
        } label: {
            HStack(spacing: Spacing.m) {
                ZStack {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundStyle(Color.omTextMuted)
                            .frame(width: 44, height: 44)
                            .background(Color.omBgElevated)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                    } else if let initial {
                        AvatarView(initial: initial, size: 44, tone: .clay)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.inter(14, weight: .semibold))
                        .foregroundStyle(Color.omText)
                    Text(subtitle)
                        .font(.inter(12))
                        .foregroundStyle(Color.omTextMuted)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: actuallySelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(actuallySelected ? Color.omAccent : Color.omBorder)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.m)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Review prompt sheet

    private func reviewPrompt(buyerID: Int, product: Product) -> some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: Spacing.xl) {
                Spacer()
                Image(systemName: "star.bubble.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.omAccent)

                VStack(spacing: Spacing.s) {
                    Text("Sale complete!")
                        .font(.serif(28))
                        .foregroundStyle(Color.omText)
                    Text("The buyer has been notified. Would you like to view your listings?")
                        .font(.inter(14))
                        .foregroundStyle(Color.omTextMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }

                Spacer()

                OMButton(label: "Done", size: .lg, fullWidth: true) {
                    showReviewPrompt = false
                    dismiss()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Actions

    private func loadConversations() async {
        isLoading = true
        defer { isLoading = false }
        conversations = (try? await MessageService.getConversations()) ?? []
        // Default selection: skip (nil)
        selectedBuyerID = nil
    }

    private func markSold() async {
        isMarking = true
        defer { isMarking = false }
        do {
            let updated = try await ProductService.markAsSold(
                id: product.id,
                buyerID: selectedBuyerID
            )
            soldProduct = updated
            onSold?(updated)
            if selectedBuyerID != nil {
                showReviewPrompt = true
            } else {
                dismiss()
            }
        } catch {}
    }
}
