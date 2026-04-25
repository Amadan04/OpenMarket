import SwiftUI

struct MyOffersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var offers: [Offer] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var selectedFilter = "All"
    @State private var rateOffer: Offer? = nil
    private let filters = ["All", "Pending", "Accepted", "Declined"]

    private var filtered: [Offer] {
        switch selectedFilter {
        case "Pending":  return offers.filter { $0.status == .pending || $0.status == .countered }
        case "Accepted": return offers.filter { $0.status == .accepted }
        case "Declined": return offers.filter { $0.status == .declined || $0.status == .withdrawn }
        default:         return offers
        }
    }

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
                        Text("MY OFFERS").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text("Offer history").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.s) {
                        ForEach(filters, id: \.self) { f in
                            OMChip(label: f, active: selectedFilter == f)
                                .onTapGesture { withAnimation { selectedFilter = f } }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .padding(.bottom, Spacing.m)

                Divider()

                if isLoading {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(0..<4, id: \.self) { _ in SkeletonRowView() }
                        }
                        .padding(.horizontal, Spacing.xl).padding(.top, Spacing.m)
                    }
                } else if let err = errorMessage {
                    VStack(spacing: Spacing.l) {
                        Spacer()
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 40)).foregroundStyle(Color.omTextMuted)
                        Text(err).font(.omBody).foregroundStyle(Color.omTextMuted)
                            .multilineTextAlignment(.center)
                        OMButton(label: "Retry", variant: .secondary, size: .md, icon: "arrow.clockwise") {
                            Task { await load() }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.x4)
                } else if filtered.isEmpty {
                    VStack(spacing: Spacing.m) {
                        Spacer()
                        Image(systemName: "tag").font(.system(size: 44)).foregroundStyle(Color.omTextSubtle)
                        Text("No offers here")
                            .font(.omTitle3).foregroundStyle(Color.omText)
                        Text("Offers you make on listings will appear here.")
                            .font(.omBody).foregroundStyle(Color.omTextMuted)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.x4)
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(filtered) { offer in
                                offerCard(offer)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.m)
                        .padding(.bottom, 80)
                    }
                    .refreshable { await load() }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await load() }
        .sheet(item: $rateOffer) { offer in
            RateSellerView(
                sellerID: offer.sellerID,
                sellerName: offer.sellerName ?? "Seller"
            )
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            offers = try await OfferService.getMyOffers()
        } catch {
            errorMessage = "Couldn't load your offers. Please try again."
        }
    }

    private func offerCard(_ offer: Offer) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.m) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.listingTitle ?? "Listing #\(offer.listingID)")
                        .font(.inter(13, weight: .semibold)).foregroundStyle(Color.omText).lineLimit(1)
                    if let seller = offer.sellerName {
                        Text("from \(seller)")
                            .font(.inter(12)).foregroundStyle(Color.omTextMuted)
                    }
                    Text(offer.amount.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                        .font(.serif(22)).foregroundStyle(Color.omAccent)
                    if let counter = offer.counterAmount, offer.status == .countered {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left.arrow.right.circle.fill")
                                .font(.system(size: 12)).foregroundStyle(Color.stone600)
                            Text("Counter: \(counter.formatted(.currency(code: "BHD").precision(.fractionLength(0))))")
                                .font(.inter(12, weight: .semibold)).foregroundStyle(Color.stone600)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    statusChip(offer.status)
                    Text(offer.createdAt, style: .relative)
                        .font(.inter(11)).foregroundStyle(Color.omTextMuted)
                }
            }

            if !offer.note.isEmpty {
                Text("\"\(offer.note)\"")
                    .font(.inter(12)).foregroundStyle(Color.omTextMuted).italic()
            }

            if offer.status == .accepted {
                Button {
                    rateOffer = offer
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill").font(.system(size: 11)).foregroundStyle(Color.omAccent)
                        Text("Rate seller")
                            .font(.inter(13, weight: .semibold))
                            .foregroundStyle(Color.omAccent)
                    }
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, 6)
                    .background(Color.omAccentSoft)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.l)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(
            statusColor(offer.status).opacity(offer.status == .pending || offer.status == .countered ? 0.3 : 0.1),
            lineWidth: 1))
    }

    private func statusChip(_ status: OfferStatus) -> some View {
        let (label, color) = statusInfo(status)
        return Text(label.uppercased())
            .font(.omMicro)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }

    private func statusInfo(_ status: OfferStatus) -> (String, Color) {
        switch status {
        case .pending:   return ("Pending",   Color.omAccent)
        case .accepted:  return ("Accepted",  Color.omOk)
        case .declined:  return ("Declined",  Color.omError)
        case .countered: return ("Countered", Color.stone600)
        case .withdrawn: return ("Withdrawn", Color.omTextMuted)
        }
    }

    private func statusColor(_ status: OfferStatus) -> Color { statusInfo(status).1 }
}
