import SwiftUI

struct AllIncomingOffersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @State private var offersByListing: [Int: [Offer]] = [:]
    @State private var isLoading = true

    private var allOffers: [(listing: Product, offers: [Offer])] {
        profileVM.myListings.compactMap { listing in
            guard let offers = offersByListing[listing.id], !offers.isEmpty else { return nil }
            return (listing: listing, offers: offers)
        }
    }

    private var pendingTotal: Int {
        offersByListing.values.flatMap { $0 }.filter { $0.status == .pending }.count
    }

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Incoming Offers")
                            .font(.serif(28))
                            .foregroundStyle(Color.omText)
                        if pendingTotal > 0 {
                            Text("\(pendingTotal) pending response")
                                .font(.inter(13))
                                .foregroundStyle(Color.omAccent)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.l)
                .padding(.bottom, Spacing.m)

                Divider()

                if isLoading {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(0..<4, id: \.self) { _ in SkeletonRowView() }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.m)
                    }
                } else if allOffers.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                            ForEach(allOffers, id: \.listing.id) { entry in
                                listingSection(entry.listing, offers: entry.offers)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.m)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            guard let userID = authViewModel.currentUser?.id else { return }
            await profileVM.loadMyListings(userID: userID)
            await loadAllOffers()
            isLoading = false
        }
    }

    private func loadAllOffers() async {
        await withTaskGroup(of: (Int, [Offer]).self) { group in
            for listing in profileVM.myListings {
                group.addTask {
                    let offers = (try? await OfferService.getOffers(forListingID: listing.id)) ?? []
                    return (listing.id, offers)
                }
            }
            for await (id, offers) in group {
                offersByListing[id] = offers
            }
        }
    }

    private func listingSection(_ listing: Product, offers: [Offer]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            // Listing header
            HStack(spacing: Spacing.m) {
                AsyncImage(url: URL(string: listing.images.first ?? "")) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Rectangle().fill(Color.cream200)
                    }
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))

                VStack(alignment: .leading, spacing: 2) {
                    Text(listing.title)
                        .font(.inter(14, weight: .semibold))
                        .foregroundStyle(Color.omText)
                        .lineLimit(1)
                    Text(listing.price.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                        .font(.inter(13, weight: .bold))
                        .foregroundStyle(Color.omAccent)
                }
                Spacer()
                Text("\(offers.count) offer\(offers.count == 1 ? "" : "s")")
                    .font(.inter(12))
                    .foregroundStyle(Color.omTextMuted)
            }
            .padding(Spacing.m)
            .background(Color.omBgElevated)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))

            // Offer rows
            ForEach(offers) { offer in
                OfferRowView(offer: offer, listingPrice: listing.price)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Spacer()
            Image(systemName: "tag")
                .font(.system(size: 48))
                .foregroundStyle(Color.omTextSubtle)
            Text("No offers yet")
                .font(.omTitle3)
                .foregroundStyle(Color.omText)
            Text("When buyers make offers on your listings, they'll appear here.")
                .font(.omBody)
                .foregroundStyle(Color.omTextMuted)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, Spacing.x4)
    }
}

// Self-contained offer row with its own respond logic
private struct OfferRowView: View {
    let offer: Offer
    let listingPrice: Double
    @State private var currentOffer: Offer
    @State private var isResponding = false
    @State private var showCounterSheet = false
    @State private var counterText = ""

    init(offer: Offer, listingPrice: Double) {
        self.offer = offer
        self.listingPrice = listingPrice
        _currentOffer = State(initialValue: offer)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(alignment: .top, spacing: Spacing.m) {
                AvatarView(initial: (currentOffer.buyerName ?? "B").prefix(1).description, size: 40, tone: .clay)

                VStack(alignment: .leading, spacing: 3) {
                    Text(currentOffer.buyerName ?? "Buyer #\(currentOffer.buyerID)")
                        .font(.inter(14, weight: .semibold))
                        .foregroundStyle(Color.omText)
                    Text(currentOffer.createdAt, style: .relative)
                        .font(.inter(12))
                        .foregroundStyle(Color.omTextMuted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(currentOffer.amount.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                        .font(.serif(20))
                        .foregroundStyle(Color.omAccent)
                    Text("vs \(listingPrice.formatted(.currency(code: "BHD").precision(.fractionLength(0))))")
                        .font(.inter(11))
                        .foregroundStyle(Color.omTextMuted)
                }
            }

            if !currentOffer.note.isEmpty {
                Text("\"\(currentOffer.note)\"")
                    .font(.inter(13))
                    .foregroundStyle(Color.omText)
                    .italic()
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, Spacing.s)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.omBgSunken)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
            }

            if let counter = currentOffer.counterAmount, currentOffer.status == .countered {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .font(.system(size: 13)).foregroundStyle(Color.stone600)
                    Text("You countered with \(counter.formatted(.currency(code: "BHD").precision(.fractionLength(0))))")
                        .font(.inter(13, weight: .semibold)).foregroundStyle(Color.stone600)
                }
            }

            HStack(spacing: Spacing.s) {
                statusChip(currentOffer.status)
                Spacer()
                if currentOffer.status == .pending {
                    if isResponding {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Button {
                            Task { await respond(action: "decline") }
                        } label: {
                            Text("Decline")
                                .font(.inter(13, weight: .semibold))
                                .foregroundStyle(Color.omError)
                                .frame(width: 70, height: 32)
                                .background(Color.omError.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                                .overlay(RoundedRectangle(cornerRadius: Radius.sm).stroke(Color.omError.opacity(0.2), lineWidth: 1))
                        }
                        .buttonStyle(.plain)

                        Button { showCounterSheet = true } label: {
                            Text("Counter")
                                .font(.inter(13, weight: .semibold))
                                .foregroundStyle(Color.stone600)
                                .frame(width: 70, height: 32)
                                .background(Color.omBgSunken)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                        }
                        .buttonStyle(.plain)

                        Button {
                            Task { await respond(action: "accept") }
                        } label: {
                            Text("Accept")
                                .font(.inter(13, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 70, height: 32)
                                .background(Color.omOk)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(Spacing.l)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(
            currentOffer.status == .pending ? Color.omAccent.opacity(0.3) : Color.omBorder, lineWidth: 1))
        .sheet(isPresented: $showCounterSheet) {
            counterSheet
        }
    }

    private func respond(action: String, counterAmount: Double? = nil) async {
        isResponding = true
        defer { isResponding = false }
        if let updated = try? await OfferService.respond(offerID: currentOffer.id, action: action, counterAmount: counterAmount) {
            currentOffer = updated
        }
    }

    private var counterSheet: some View {
        VStack(spacing: Spacing.l) {
            Text("Counter Offer").font(.serif(24)).foregroundStyle(Color.omText)
            TextField("Your counter amount (BHD)", text: $counterText)
                .keyboardType(.decimalPad)
                .font(.inter(16))
                .padding(Spacing.m)
                .background(Color.omBgSunken)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            HStack(spacing: Spacing.m) {
                OMButton(label: "Cancel", variant: .secondary, size: .md, fullWidth: true) {
                    showCounterSheet = false
                }
                OMButton(label: "Send", size: .md, fullWidth: true) {
                    if let amt = Double(counterText), amt > 0 {
                        showCounterSheet = false
                        Task { await respond(action: "counter", counterAmount: amt) }
                    }
                }
            }
        }
        .padding(Spacing.xl)
        .presentationDetents([.height(280)])
    }

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
        return Text(label.uppercased())
            .font(.omMicro)
            .foregroundStyle(color)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
