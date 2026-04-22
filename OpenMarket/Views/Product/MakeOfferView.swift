import SwiftUI

struct MakeOfferView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    @State private var offerText = ""
    @State private var note = ""
    @State private var isSending = false
    @State private var sent = false
    @FocusState private var offerFocused: Bool

    private var suggestedOffers: [Double] {
        let p = product.price
        return [p * 0.9, p * 0.8, p * 0.7].map { ($0 / 5).rounded() * 5 }
    }

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
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
                    Text("Make an Offer").font(.inter(16, weight: .bold)).foregroundStyle(Color.omText)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)
                .padding(.bottom, Spacing.l)

                ScrollView {
                    VStack(spacing: Spacing.l) {
                        // Product row
                        HStack(spacing: Spacing.m) {
                            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                                switch phase {
                                case .success(let img): img.resizable().scaledToFill()
                                default: Color.cream200
                                }
                            }
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(product.title).font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText).lineLimit(1)
                                Text("Listed for \(product.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))")
                                    .font(.inter(13)).foregroundStyle(Color.omTextMuted)
                            }
                            Spacer()
                        }
                        .padding(Spacing.m)
                        .background(Color.omBgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))

                        // Offer input
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Your Offer".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                            HStack {
                                Text("$").font(.serif(28)).foregroundStyle(Color.omAccent)
                                TextField("0", text: $offerText)
                                    .font(.serif(28))
                                    .foregroundStyle(Color.omText)
                                    .keyboardType(.decimalPad)
                                    .focused($offerFocused)
                            }
                            .padding(Spacing.l)
                            .background(Color.omBgElevated)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                            .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(
                                offerFocused ? Color.omAccent : Color.omBorder, lineWidth: offerFocused ? 1.5 : 1))
                        }

                        // Quick suggestions
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Quick offers".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                            HStack(spacing: Spacing.s) {
                                ForEach(suggestedOffers, id: \.self) { amt in
                                    Button {
                                        offerText = String(format: "%.0f", amt)
                                    } label: {
                                        Text(amt.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                                            .font(.inter(13, weight: .semibold))
                                            .foregroundStyle(offerText == String(format: "%.0f", amt) ? .white : Color.omText)
                                            .padding(.horizontal, Spacing.m)
                                            .padding(.vertical, Spacing.s)
                                            .background(offerText == String(format: "%.0f", amt) ? Color.omAccent : Color.omBgElevated)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(Color.omBorder, lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }
                        }

                        // Note
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Add a note (optional)".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                            TextField("e.g. I can pick up today", text: $note, axis: .vertical)
                                .font(.omCallout)
                                .foregroundStyle(Color.omText)
                                .lineLimit(3)
                                .padding(Spacing.m)
                                .background(Color.omBgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                        }

                        if sent {
                            HStack(spacing: Spacing.s) {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.omOk)
                                Text("Offer sent to seller!").font(.inter(14, weight: .semibold)).foregroundStyle(Color.omOk)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                    .animation(.spring(response: 0.35), value: sent)
                }

                // Send button
                VStack {
                    OMButton(
                        label: "Send Offer",
                        size: .lg,
                        fullWidth: true,
                        icon: "paperplane.fill",
                        isLoading: isSending
                    ) {
                        Task { await sendOffer() }
                    }
                    .disabled(!canSend)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .background(Color.omBg)
                .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear { offerFocused = true }
    }

    private var canSend: Bool {
        if let val = Double(offerText), val > 0 { return true }
        return false
    }

    private func sendOffer() async {
        guard let val = Double(offerText), val > 0 else { return }
        isSending = true
        defer { isSending = false }

        var message = "💰 Offer: \(val.formatted(.currency(code: "USD").precision(.fractionLength(0)))) for \"\(product.title)\""
        if !note.trimmingCharacters(in: .whitespaces).isEmpty {
            message += "\n\"\(note.trimmingCharacters(in: .whitespaces))\""
        }

        do {
            let vm = ChatViewModel()
            await vm.openChat(with: product.userID)
            await vm.sendMessage(content: message)
            withAnimation(.spring(response: 0.4)) { sent = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
        }
    }
}
