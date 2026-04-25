import SwiftUI
import MapKit

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showChat = false
    @State private var showOffer = false
    @State private var showReport = false
    @State private var showRateSeller = false
    @State private var showSellerProfile = false
    @State private var showGallery = false
    @State private var showAccepted = false
    @State private var showWithdrawConfirm = false
    @State private var imageIndex = 0

    init(product: Product) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Image carousel
                imageCarousel

                VStack(alignment: .leading, spacing: 0) {
                        // Condition + age
                        HStack {
                            Text("\(viewModel.product.condition.uppercased()) · \(viewModel.product.category.uppercased())")
                                .font(.omMicro)
                                .foregroundStyle(Color.sage500)
                            Spacer()
                            Text(viewModel.product.createdAt, style: .relative)
                                .font(.omMicro)
                                .foregroundStyle(Color.omTextMuted)
                        }
                        .padding(.top, Spacing.xl)

                        Text(viewModel.product.title)
                            .font(.serif(30))
                            .foregroundStyle(Color.omText)
                            .padding(.top, Spacing.s)

                        Text(viewModel.product.price.formatted(.currency(code: "BHD").precision(.fractionLength(0))))
                            .font(.inter(28, weight: .bold))
                            .foregroundStyle(Color.omAccent)
                            .kerning(-0.3)
                            .padding(.top, Spacing.m)

                        // Action buttons
                        if viewModel.product.isSold {
                            Text("SOLD")
                                .font(.inter(15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.m)
                                .background(Color.omTextMuted)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                                .padding(.top, Spacing.l)
                        } else if authViewModel.currentUser?.id != viewModel.product.userID {
                            VStack(spacing: Spacing.s) {
                                if let offer = viewModel.myOffer {
                                    offerStatusBanner(offer)
                                }
                                HStack(spacing: Spacing.m) {
                                    if viewModel.myOffer == nil {
                                        OMButton(label: "Make Offer", variant: .secondary, size: .lg, icon: "tag.fill") {
                                            showOffer = true
                                        }
                                    }
                                    OMButton(label: "Message", size: .lg, fullWidth: viewModel.myOffer != nil, icon: "bubble.left.fill") {
                                        showChat = true
                                    }
                                }
                            }
                            .padding(.top, Spacing.l)
                        } else {
                            OMButton(label: "Message buyer", size: .lg, fullWidth: true,  icon: "bubble.left.fill") {
                                showChat = true
                            }
                            .padding(.top, Spacing.l)
                        }

                        // Meta row
                        HStack(spacing: Spacing.xl) {
                            metaItem(title: "Location", value: viewModel.product.location.isEmpty ? "N/A" : viewModel.product.location)
                            Divider().frame(height: 32)
                            metaItem(title: "Category", value: viewModel.product.category)
                        }
                        .padding(.top, Spacing.l)
                        .padding(.bottom, Spacing.l)
                        Divider()

                        // Description
                        if !viewModel.product.description.isEmpty {
                            Text(viewModel.product.description)
                                .font(.inter(14))
                                .foregroundStyle(Color.omTextMuted)
                                .lineSpacing(6)
                                .padding(.vertical, Spacing.l)
                            Divider()
                        }

                        // Seller card
                        sellerCard.padding(.vertical, Spacing.xl)
                        Divider()

                        // Map
                        if viewModel.product.latitude != 0 {
                            pickupMap.padding(.vertical, Spacing.xl)
                        }

                        // Reviews
                        if authViewModel.currentUser?.id != viewModel.product.userID {
                            if let reviews = viewModel.reviews, reviews.reviewsCount > 0 {
                                reviewsSection(reviews).padding(.bottom, Spacing.x4)
                            } else {
                                Button { showRateSeller = true } label: {
                                    HStack(spacing: Spacing.s) {
                                        Image(systemName: "star")
                                        Text("Be the first to rate this seller")
                                    }
                                    .font(.inter(14, weight: .semibold))
                                    .foregroundStyle(Color.omAccent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Spacing.m)
                                    .background(Color.omAccentSoft)
                                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                }
                                .buttonStyle(.plain)
                                .padding(.bottom, Spacing.x4)
                            }
                        } else if let reviews = viewModel.reviews, reviews.reviewsCount > 0 {
                            reviewsSection(reviews).padding(.bottom, Spacing.x4)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .task {
            RecentlyViewedStore.shared.record(viewModel.product)
            async let reviews: () = viewModel.loadReviews()
            async let offer: () = viewModel.loadMyOffer()
            async let seller: () = viewModel.loadSellerInfo()
            _ = await (reviews, offer, seller)
            if viewModel.myOffer?.status == .accepted,
               authViewModel.currentUser?.id != viewModel.product.userID {
                showAccepted = true
            }
        }
        .sheet(isPresented: $showChat) {
            if authViewModel.currentUser != nil {
                let vm = ChatViewModel()
                let other = User(id: viewModel.product.userID, name: viewModel.sellerName, email: "", createdAt: Date())
                ChatView(viewModel: vm, otherUser: other, product: viewModel.product)
                    .task { await vm.openChat(with: viewModel.product.userID) }
            }
        }
        .sheet(isPresented: $showOffer) {
            MakeOfferView(product: viewModel.product) { offer in
                viewModel.myOffer = offer
            }
        }
        .sheet(isPresented: $showReport) {
            ReportListingView(productID: viewModel.product.id, productTitle: viewModel.product.title)
        }
        .fullScreenCover(isPresented: $showGallery) {
            ImageGalleryView(images: viewModel.product.images, currentIndex: $imageIndex)
        }
        .sheet(isPresented: $showRateSeller) {
            RateSellerView(sellerID: viewModel.product.userID, sellerName: viewModel.sellerName, product: viewModel.product)
        }
        .sheet(isPresented: $showAccepted) {
            acceptedSheet
        }
        .navigationDestination(isPresented: $showSellerProfile) {
            SellerProfileView(sellerID: viewModel.product.userID)
        }
    }

    // MARK: - Subviews

    private var imageCarousel: some View {
        ZStack(alignment: .bottom) {
            if viewModel.product.images.isEmpty {
                Rectangle().fill(Color.cream200)
                    .overlay(Image(systemName: "photo.fill").font(.system(size: 60)).foregroundStyle(Color.stone300))
                    .frame(height: 380)
            } else {
                TabView(selection: $imageIndex) {
                    ForEach(Array(viewModel.product.images.enumerated()), id: \.offset) { idx, url in
                        AsyncImage(url: URL(string: url)) { phase in
                            switch phase {
                            case .success(let img): img.resizable().scaledToFill()
                            default: Rectangle().fill(Color.cream200)
                            }
                        }
                        .frame(height: 380)
                        .clipped()
                        .tag(idx)
                        .onTapGesture { showGallery = true }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 380)
            }

            // Overlay controls
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.omText)
                        .frame(width: 40, height: 40)
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
                Spacer()
                HStack(spacing: Spacing.s) {
                    Button { Task { await viewModel.toggleFavorite() } } label: {
                        Image(systemName: viewModel.isFavorited ? "heart.fill" : "heart")
                            .font(.system(size: 17))
                            .foregroundStyle(viewModel.isFavorited ? Color.omAccent : Color.omText)
                            .frame(width: 40, height: 40)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                    }
                    Button { showReport = true } label: {
                        Image(systemName: "flag")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.omText)
                            .frame(width: 40, height: 40)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, 56)
            .frame(maxHeight: .infinity, alignment: .top)

            // Page dots
            if viewModel.product.images.count > 1 {
                HStack(spacing: 5) {
                    ForEach(0..<viewModel.product.images.count, id: \.self) { i in
                        Capsule()
                            .fill(.white.opacity(i == imageIndex ? 1 : 0.5))
                            .frame(width: i == imageIndex ? 20 : 6, height: 6)
                    }
                }
                .padding(.bottom, Spacing.m)
            }
        }
        .frame(height: 380)
    }

    private func metaItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased()).font(.inter(11)).foregroundStyle(Color.omTextMuted).kerning(0.5)
            Text(value).font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText)
        }
    }

    private var sellerCard: some View {
        Button { showSellerProfile = true } label: {
            HStack(spacing: Spacing.m) {
                AvatarView(initial: viewModel.sellerName.prefix(1).description, size: 48, tone: .sage)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(viewModel.sellerName).font(.inter(15, weight: .semibold)).foregroundStyle(Color.omText)
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 14)).foregroundStyle(Color.sage500)
                    }
                    HStack(spacing: 4) {
                        StarRatingView(rating: viewModel.reviews?.averageRating ?? 0, size: 12)
                        Text(String(format: "%.1f", viewModel.reviews?.averageRating ?? 0))
                            .font(.inter(12, weight: .semibold)).foregroundStyle(Color.omText)
                        Text("· \(viewModel.reviews?.reviewsCount ?? 0) reviews")
                            .font(.inter(12)).foregroundStyle(Color.omTextMuted)
                    }
                }
                Spacer()
                OMButton(label: "View", variant: .secondary, size: .sm) { showSellerProfile = true }
            }
            .padding(Spacing.l)
            .background(Color.omBgElevated)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var pickupMap: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Pickup location").font(.inter(15, weight: .semibold)).foregroundStyle(Color.omText)
            Map(position: .constant(MapCameraPosition.region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: viewModel.product.latitude, longitude: viewModel.product.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))) {
                Marker("", coordinate: CLLocationCoordinate2D(latitude: viewModel.product.latitude, longitude: viewModel.product.longitude))
                    .tint(Color.omAccent)
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(alignment: .bottomLeading) {
                Text("Approx. area shown")
                    .font(.inter(12, weight: .semibold))
                    .foregroundStyle(Color.omText)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 4)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                    .padding(Spacing.m)
            }
        }
    }

    private func reviewsSection(_ data: ReviewsResponse) -> some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack {
                Text("Reviews (\(data.reviewsCount))").font(.inter(15, weight: .semibold)).foregroundStyle(Color.omText)
                Spacer()
                if authViewModel.currentUser?.id != viewModel.product.userID {
                    Button {
                        showRateSeller = true
                    } label: {
                        Label("Rate Seller", systemImage: "star.fill")
                            .font(.inter(13, weight: .semibold))
                            .foregroundStyle(Color.omAccent)
                    }
                    .buttonStyle(.plain)
                }
            }
            ForEach(data.reviews.prefix(3)) { review in
                VStack(alignment: .leading, spacing: Spacing.s) {
                    HStack {
                        AvatarView(initial: review.reviewerName.prefix(1).description, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(review.reviewerName.isEmpty ? "Anonymous" : review.reviewerName)
                                .font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText)
                            StarRatingView(rating: Double(review.rating), size: 11)
                        }
                        Spacer()
                        Text(review.createdAt, style: .relative).font(.inter(12)).foregroundStyle(Color.omTextMuted)
                    }
                    if !review.comment.isEmpty {
                        Text(review.comment).font(.inter(14)).foregroundStyle(Color.omText).lineSpacing(4)
                    }
                }
                Divider()
            }
        }
    }

    @ViewBuilder
    private func offerStatusBanner(_ offer: Offer) -> some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: offerStatusIcon(offer.status))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(offerStatusColor(offer.status))

            VStack(alignment: .leading, spacing: 1) {
                Text(offerStatusLabel(offer))
                    .font(.inter(13, weight: .semibold))
                    .foregroundStyle(offerStatusColor(offer.status))
                if let counter = offer.counterAmount, offer.status == .countered {
                    Text("Counter offer: \(counter.formatted(.currency(code: "BHD").precision(.fractionLength(0))))")
                        .font(.inter(12))
                        .foregroundStyle(Color.omTextMuted)
                }
            }

            Spacer()

            if offer.status == .pending {
                Button {
                    showWithdrawConfirm = true
                } label: {
                    if viewModel.isWithdrawingOffer {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Text("Withdraw")
                            .font(.inter(12, weight: .semibold))
                            .foregroundStyle(Color.omTextMuted)
                    }
                }
                .buttonStyle(.plain)
                .confirmationDialog("Withdraw your offer?", isPresented: $showWithdrawConfirm, titleVisibility: .visible) {
                    Button("Withdraw Offer", role: .destructive) {
                        Task { await viewModel.withdrawOffer() }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Your offer will be cancelled and the seller will be notified.")
                }
            } else if offer.status == .countered {
                HStack(spacing: Spacing.s) {
                    Button {
                        Task { await viewModel.declineCounter() }
                    } label: {
                        Text("Decline")
                            .font(.inter(12, weight: .semibold))
                            .foregroundStyle(Color.omError)
                    }
                    .buttonStyle(.plain)
                    Button {
                        Task { await viewModel.acceptCounter() }
                    } label: {
                        Text("Accept")
                            .font(.inter(12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.m)
                            .padding(.vertical, 5)
                            .background(Color.omOk)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(offerStatusColor(offer.status).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
        .overlay(RoundedRectangle(cornerRadius: Radius.sm).stroke(offerStatusColor(offer.status).opacity(0.25), lineWidth: 1))
        .animation(.spring(response: 0.35), value: offer.status)
    }

    private func offerStatusLabel(_ offer: Offer) -> String {
        switch offer.status {
        case .pending:   return "Offer of \(offer.amount.formatted(.currency(code: "BHD").precision(.fractionLength(0)))) pending"
        case .accepted:  return "Offer accepted!"
        case .declined:  return "Offer declined"
        case .countered: return "Seller countered your offer"
        case .withdrawn: return "Offer withdrawn"
        }
    }

    private func offerStatusIcon(_ status: OfferStatus) -> String {
        switch status {
        case .pending:   return "clock"
        case .accepted:  return "checkmark.circle.fill"
        case .declined:  return "xmark.circle.fill"
        case .countered: return "arrow.left.arrow.right.circle.fill"
        case .withdrawn: return "minus.circle"
        }
    }

    private func offerStatusColor(_ status: OfferStatus) -> Color {
        switch status {
        case .pending:   return Color.omAccent
        case .accepted:  return Color.omOk
        case .declined:  return Color.omError
        case .countered: return Color.stone600
        case .withdrawn: return Color.omTextMuted
        }
    }

    private var acceptedSheet: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.omOk)

            VStack(spacing: Spacing.s) {
                Text("Offer Accepted!")
                    .font(.serif(30))
                    .foregroundStyle(Color.omText)
                Text("The seller has accepted your offer of \(viewModel.myOffer?.amount.formatted(.currency(code: "BHD").precision(.fractionLength(0))) ?? ""). Message them to arrange pickup and payment.")
                    .font(.inter(15))
                    .foregroundStyle(Color.omTextMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, Spacing.xl)

            Spacer()

            VStack(spacing: Spacing.m) {
                OMButton(label: "Message Seller", size: .lg, fullWidth: true, icon: "bubble.left.fill") {
                    showAccepted = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showChat = true
                    }
                }
                Button("Dismiss") {
                    showAccepted = false
                }
                .font(.inter(14))
                .foregroundStyle(Color.omTextMuted)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.x4)
        }
        .presentationDetents([.medium])
    }
}
