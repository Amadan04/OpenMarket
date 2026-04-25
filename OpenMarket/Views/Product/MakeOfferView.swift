import SwiftUI

struct MakeOfferView: View {
    let product: Product
    var onOfferSent: ((Offer) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var offerText = ""
    @State private var note = ""
    @State private var isSending = false
    @State private var errorMessage: String? = nil
    @FocusState private var offerFocused: Bool

    private var suggestedOffers: [Double] {
        let p = product.price
        return [p * 0.9, p * 0.8, p * 0.7].map { ($0 / 5).rounded() * 5 }
    }

    var body: some View {
        VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5)
                    .padding(.top, Spacing.m)

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
                                Text(product.title)
                                    .font(.inter(14, weight: .semibold))
                                    .foregroundStyle(Color.omText)
                                    .lineLimit(1)
                                Text("Listed for \(product.price.formatted(.currency(code: "BHD").precision(.fractionLength(0))))")
                                    .font(.inter(13))
                                    .foregroundStyle(Color.omTextMuted)
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
                                Text("BHD").font(.inter(14, weight: .semibold)).foregroundStyle(Color.omAccent)
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
                                offerFocused ? Color.omAccent : Color.omBorder,
                                lineWidth: offerFocused ? 1.5 : 1))
                        }

                        // Quick suggestions
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Quick offers".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                            HStack(spacing: Spacing.s) {
                                ForEach(suggestedOffers, id: \.self) { amt in
                                    Button {
                                        offerText = String(format: "%.0f", amt)
                                    } label: {
                                        Text(amt.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
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

                        if let err = errorMessage {
                            HStack(spacing: Spacing.s) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Color.omError)
                                Text(err).font(.inter(13)).foregroundStyle(Color.omError)
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                    .animation(.spring(response: 0.35), value: errorMessage)
                }

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
        .presentationBackground(Color.omBg)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .ignoresSafeArea(.keyboard)
        .onAppear { offerFocused = true }
    }

    private var canSend: Bool {
        guard let val = Double(offerText) else { return false }
        return val > 0
    }

    private func sendOffer() async {
        guard let val = Double(offerText), val > 0 else { return }
        isSending = true
        errorMessage = nil
        defer { isSending = false }

        do {
            let offer = try await OfferService.create(
                listingID: product.id,
                amount: val,
                note: note.trimmingCharacters(in: .whitespaces)
            )
            onOfferSent?(offer)
            dismiss()
        } catch let APIError.serverError(msg) {
            withAnimation { errorMessage = msg }
        } catch {
            withAnimation { errorMessage = "Failed to send offer. Please try again." }
        }
    }
}
