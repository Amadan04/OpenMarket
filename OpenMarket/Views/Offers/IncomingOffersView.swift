import SwiftUI

struct IncomingOffersView: View {
    let product: Product
    @StateObject private var viewModel = OfferViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var showCounterSheet = false
    @State private var counteringOffer: Offer? = nil
    @State private var counterText = ""

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 40, height: 40)
                            .background(Color.omBgElevated)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OFFERS").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text(product.title)
                            .font(.serif(22))
                            .foregroundStyle(Color.omText)
                            .lineLimit(1)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                    if viewModel.pendingCount > 0 {
                        Text("\(viewModel.pendingCount) pending")
                            .font(.inter(12, weight: .semibold))
                            .foregroundStyle(Color.omAccent)
                            .padding(.horizontal, Spacing.s)
                            .padding(.vertical, 4)
                            .background(Color.omAccentSoft)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                Divider()

                if viewModel.isLoading {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(0..<4, id: \.self) { _ in SkeletonRowView() }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.m)
                    }
                } else if viewModel.offers.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(viewModel.offers) { offer in
                                offerRow(offer)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.m)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await viewModel.loadOffers(forListingID: product.id) }
        .sheet(isPresented: $showCounterSheet) {
            counterSheet
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Image(systemName: "tag")
                .font(.system(size: 40))
                .foregroundStyle(Color.omTextMuted)
            Text("No offers yet")
                .font(.omBodyMed)
                .foregroundStyle(Color.omTextMuted)
            Text("Offers on this listing will appear here.")
                .font(.inter(13))
                .foregroundStyle(Color.omTextSubtle)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.xl)
    }

    private func offerRow(_ offer: Offer) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            // Buyer + amount
            HStack(alignment: .top, spacing: Spacing.m) {
                AvatarView(initial: "B", size: 44, tone: .clay)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Buyer #\(offer.buyerID)")
                        .font(.inter(14, weight: .semibold))
                        .foregroundStyle(Color.omText)
                    Text(offer.createdAt, style: .relative)
                        .font(.inter(12))
                        .foregroundStyle(Color.omTextMuted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(offer.amount.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                        .font(.serif(22))
                        .foregroundStyle(Color.omAccent)
                    Text("vs \(product.price.formatted(.currency(code: "USD").precision(.fractionLength(0)))) listed")
                        .font(.inter(11))
                        .foregroundStyle(Color.omTextMuted)
                }
            }

            // Note
            if !offer.note.isEmpty {
                Text("\"\(offer.note)\"")
                    .font(.inter(13))
                    .foregroundStyle(Color.omText)
                    .italic()
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, Spacing.s)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.omBgSunken)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            }

            // Counter amount shown if already countered
            if let counter = offer.counterAmount, offer.status == .countered {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.stone600)
                    Text("You countered with \(counter.formatted(.currency(code: "USD").precision(.fractionLength(0))))")
                        .font(.inter(13, weight: .semibold))
                        .foregroundStyle(Color.stone600)
                }
            }

            // Status badge + actions
            HStack(spacing: Spacing.s) {
                statusChip(offer.status)
                Spacer()
                if offer.status == .pending {
                    actionButtons(offer)
                }
            }
        }
        .padding(Spacing.l)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(
            offer.status == .pending ? Color.omAccent.opacity(0.3) : Color.omBorder, lineWidth: 1))
    }

    @ViewBuilder
    private func statusChip(_ status: OfferStatus) -> some View {
        let (label, color): (String, Color) = {
            switch status {
            case .pending:   return ("Pending", Color.omAccent)
            case .accepted:  return ("Accepted", Color.omOk)
            case .declined:  return ("Declined", Color.omError)
            case .countered: return ("Countered", Color.stone600)
            case .withdrawn: return ("Withdrawn", Color.omTextMuted)
            }
        }()

        Text(label.uppercased())
            .font(.omMicro)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    @ViewBuilder
    private func actionButtons(_ offer: Offer) -> some View {
        let isResponding = viewModel.respondingID == offer.id

        HStack(spacing: Spacing.s) {
            Button {
                Task { await viewModel.respond(offerID: offer.id, action: "decline") }
            } label: {
                if isResponding {
                    ProgressView().scaleEffect(0.7).frame(width: 70, height: 32)
                } else {
                    Text("Decline")
                        .font(.inter(13, weight: .semibold))
                        .foregroundStyle(Color.omError)
                        .frame(width: 70, height: 32)
                        .background(Color.omError.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                        .overlay(RoundedRectangle(cornerRadius: Radius.sm).stroke(Color.omError.opacity(0.2), lineWidth: 1))
                }
            }
            .buttonStyle(.plain)
            .disabled(isResponding)

            Button {
                counteringOffer = offer
                counterText = ""
                showCounterSheet = true
            } label: {
                Text("Counter")
                    .font(.inter(13, weight: .semibold))
                    .foregroundStyle(Color.stone600)
                    .frame(width: 70, height: 32)
                    .background(Color.stone600.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                    .overlay(RoundedRectangle(cornerRadius: Radius.sm).stroke(Color.stone600.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(isResponding)

            Button {
                Task { await viewModel.respond(offerID: offer.id, action: "accept") }
            } label: {
                Text("Accept")
                    .font(.inter(13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 32)
                    .background(Color.omOk)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            }
            .buttonStyle(.plain)
            .disabled(isResponding)
        }
    }

    private var counterSheet: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5)
                    .padding(.top, Spacing.m)

                HStack {
                    Button { showCounterSheet = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 32, height: 32)
                            .background(Color.omBgSunken)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Counter Offer").font(.inter(16, weight: .bold)).foregroundStyle(Color.omText)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)
                .padding(.bottom, Spacing.l)

                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text("Your counter price".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                    HStack {
                        Text("$").font(.serif(28)).foregroundStyle(Color.omAccent)
                        TextField("0", text: $counterText)
                            .font(.serif(28))
                            .foregroundStyle(Color.omText)
                            .keyboardType(.decimalPad)
                    }
                    .padding(Spacing.l)
                    .background(Color.omBgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omAccent, lineWidth: 1.5))
                }
                .padding(.horizontal, Spacing.xl)

                Spacer()

                OMButton(
                    label: "Send Counter",
                    size: .lg,
                    fullWidth: true,
                    icon: "arrow.left.arrow.right"
                ) {
                    guard let offer = counteringOffer,
                          let val = Double(counterText), val > 0 else { return }
                    Task {
                        await viewModel.respond(offerID: offer.id, action: "counter", counterAmount: val)
                        showCounterSheet = false
                    }
                }
                .disabled(Double(counterText) == nil || Double(counterText) ?? 0 <= 0)
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.x4)
            }
        }
        .presentationDetents([.medium])
    }
}
