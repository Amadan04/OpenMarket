import SwiftUI
import MapKit

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showChat = false
    @State private var showSellerProfile = false
    @State private var imageIndex = 0

    init(product: Product) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Image carousel
                    imageCarousel

                    VStack(alignment: .leading, spacing: 0) {
                        // Condition + age
                        HStack {
                            Text("LIKE NEW · \(viewModel.product.category.uppercased())")
                                .font(.omMicro)
                                .foregroundStyle(Color.sage500)
                            Spacer()
                            Text("Posted recently")
                                .font(.omMicro)
                                .foregroundStyle(Color.omTextMuted)
                        }
                        .padding(.top, Spacing.xl)

                        Text(viewModel.product.title)
                            .font(.serif(30))
                            .foregroundStyle(Color.omText)
                            .padding(.top, Spacing.s)

                        Text(viewModel.product.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                            .font(.inter(28, weight: .bold))
                            .foregroundStyle(Color.omAccent)
                            .kerning(-0.3)
                            .padding(.top, Spacing.m)

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
                        if let reviews = viewModel.reviews, reviews.reviewsCount > 0 {
                            reviewsSection(reviews).padding(.bottom, Spacing.x4)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)

                    Color.clear.frame(height: 120) // bottom padding for sticky bar
                }
            }
            .ignoresSafeArea(edges: .top)

            // Sticky bottom bar
            stickyBar
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadReviews()
        }
        .sheet(isPresented: $showChat) {
            if let user = authViewModel.currentUser {
                let vm = ChatViewModel()
                let other = User(id: viewModel.product.userID, name: "Seller", email: "", createdAt: Date())
                ChatView(viewModel: vm, otherUser: other)
                    .task { await vm.openChat(with: viewModel.product.userID) }
            }
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
                    Image(systemName: "ellipsis")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.omText)
                        .frame(width: 40, height: 40)
                        .background(.regularMaterial)
                        .clipShape(Circle())
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
                AvatarView(initial: "S", size: 48, tone: .sage)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Seller").font(.inter(15, weight: .semibold)).foregroundStyle(Color.omText)
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
            Text("Reviews (\(data.reviewsCount))").font(.inter(15, weight: .semibold)).foregroundStyle(Color.omText)
            ForEach(data.reviews.prefix(3)) { review in
                VStack(alignment: .leading, spacing: Spacing.s) {
                    HStack {
                        AvatarView(initial: "U", size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("User #\(review.reviewerID)").font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText)
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

    private var stickyBar: some View {
        HStack(spacing: Spacing.m) {
            Button { Task { await viewModel.toggleFavorite() } } label: {
                Image(systemName: viewModel.isFavorited ? "heart.fill" : "heart")
                    .font(.system(size: 22))
                    .foregroundStyle(viewModel.isFavorited ? Color.omAccent : Color.omText)
                    .frame(width: 56, height: 56)
                    .background(Color.omBgElevated)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.omBorderStrong, lineWidth: 1))
            }

            OMButton(label: "Message Seller", size: .lg, fullWidth: true, icon: "bubble.left.fill") {
                showChat = true
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.m)
        .padding(.bottom, Spacing.xl)
        .background(
            Rectangle().fill(.ultraThinMaterial)
                .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
                .ignoresSafeArea()
        )
    }
}
