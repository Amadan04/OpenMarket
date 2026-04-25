import SwiftUI

struct SellerProfileView: View {
    let sellerID: Int
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = 1 // 0=listings, 1=reviews, 2=about
    @State private var showChat = false
    @Environment(\.dismiss) private var dismiss
    @State private var isFollowing = false
    @State private var showBlockConfirm = false
    @State private var isBlocked = false
    @State private var isTogglingBlock = false
    @State private var sellerName = "Seller"
    @State private var sellerJoinedDate: Date? = nil

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    // Nav
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
                        Spacer()
                        Button { showBlockConfirm = true } label: {
                        Group {
                            if isTogglingBlock {
                                ProgressView().scaleEffect(0.7)
                            } else {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(Color.omText)
                            }
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.omBgElevated)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                    }
                    .disabled(isTogglingBlock)
                    .confirmationDialog(
                        isBlocked ? "Unblock this user?" : "Block this user?",
                        isPresented: $showBlockConfirm,
                        titleVisibility: .visible
                    ) {
                        if isBlocked {
                            Button("Unblock") {
                                Task { await toggleBlock() }
                            }
                        } else {
                            Button("Block", role: .destructive) {
                                Task { await toggleBlock() }
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text(isBlocked
                            ? "Their listings will appear again and they can message you."
                            : "Their listings will be hidden and they won't be able to message you.")
                    }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.m)

                    // Profile header
                    VStack(spacing: Spacing.m) {
                        ZStack(alignment: .bottomTrailing) {
                            AvatarView(initial: sellerName.prefix(1).description, size: 96, tone: .sage)
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.sage500)
                                .background(Circle().fill(.white).padding(-2))
                        }

                        Text(sellerName)
                            .font(.serif(28))
                            .foregroundStyle(Color.omText)
                        if let date = sellerJoinedDate {
                            Text("Joined \(date.formatted(.dateTime.month(.wide).year()))")
                                .font(.inter(13))
                                .foregroundStyle(Color.omTextMuted)
                        }
                    }
                    .padding(.top, Spacing.l)

                    // Stats card
                    HStack(spacing: 0) {
                        statItem(value: String(format: "%.1f", viewModel.myReviews?.averageRating ?? 0), label: "Rating", isRating: true)
                        Divider().frame(height: 40)
                        statItem(value: "\(viewModel.myListings.count)", label: "Listings")
                        Divider().frame(height: 40)
                        statItem(value: "2h", label: "Replies in")
                    }
                    .padding(Spacing.m)
                    .background(Color.omBgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                    .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.l)

                    // Action buttons
                    HStack(spacing: Spacing.s) {
                        OMButton(label: "Message", variant: .dark, size: .md, icon: "bubble.left.fill") { showChat = true }
                        OMButton(
                            label: isFollowing ? "Following ✓" : "Follow",
                            variant: isFollowing ? .primary : .secondary,
                            size: .md
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isFollowing.toggle()
                            }
                        }
                    }
                    .padding(.top, Spacing.m)

                    // Tabs
                    HStack(spacing: 0) {
                        ForEach([(0,"Listings"), (1,"Reviews"), (2,"About")], id: \.0) { i, label in
                            Button {
                                withAnimation { selectedTab = i }
                            } label: {
                                VStack(spacing: Spacing.s) {
                                    Text(label).font(.inter(14, weight: .semibold))
                                        .foregroundStyle(selectedTab == i ? Color.omText : Color.omTextMuted)
                                    Rectangle()
                                        .fill(selectedTab == i ? Color.omAccent : Color.clear)
                                        .frame(height: 2)
                                }
                                .padding(.top, Spacing.m)
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.m)
                    Divider()

                    // Tab content
                    switch selectedTab {
                    case 0: listingsTab
                    case 1: reviewsTab
                    default: aboutTab
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .overlay {
            if isBlocked {
                ZStack {
                    Color.omBg.ignoresSafeArea()
                    VStack(spacing: Spacing.l) {
                        Image(systemName: "nosign")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.omError)
                        Text("User blocked").font(.serif(26)).foregroundStyle(Color.omText)
                        Text("You won't see their listings or receive messages from them.")
                            .font(.omBody).foregroundStyle(Color.omTextMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.x4)
                        OMButton(label: "Go back", variant: .secondary, size: .lg) { dismiss() }
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isBlocked)
        .task {
            async let listings: () = viewModel.loadMyListings(userID: sellerID)
            async let reviews: () = viewModel.loadMyReviews(userID: sellerID)
            async let info: () = loadSellerInfo()
            let blocked = await BlockService.isBlocked(userID: sellerID)
            _ = await (listings, reviews, info)
            isBlocked = blocked
        }
        .sheet(isPresented: $showChat) {
            let vm = ChatViewModel()
            let other = User(id: sellerID, name: sellerName, email: "", createdAt: Date())
            ChatView(viewModel: vm, otherUser: other)
                .task { await vm.openChat(with: sellerID) }
        }
    }

    private func statItem(value: String, label: String, isRating: Bool = false) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 3) {
                if isRating { Image(systemName: "star.fill").font(.system(size: 14)).foregroundStyle(Color.omAccent) }
                Text(value).font(.inter(18, weight: .bold)).foregroundStyle(Color.omText)
            }
            Text(label.uppercased()).font(.omMicro).foregroundStyle(Color.omTextMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var listingsTab: some View {
        LazyVStack(spacing: Spacing.m) {
            ForEach(viewModel.myListings) { product in
                NavigationLink { ProductDetailView(product: product) } label: {
                    ProductRowCard(product: product)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }

    private var reviewsTab: some View {
        VStack(spacing: Spacing.l) {
            if let data = viewModel.myReviews {
                // Summary
                HStack(spacing: Spacing.xl) {
                    VStack(spacing: 6) {
                        Text(String(format: "%.1f", data.averageRating))
                            .font(.serif(44)).foregroundStyle(Color.omText)
                        StarRatingView(rating: data.averageRating, size: 11)
                        Text("\(data.reviewsCount) reviews").font(.inter(11)).foregroundStyle(Color.omTextMuted)
                    }
                    VStack(spacing: 3) {
                        ForEach([5,4,3,2,1], id: \.self) { star in
                            let pct = data.reviewsCount > 0 ?
                                Double(data.reviews.filter { $0.rating == star }.count) / Double(data.reviewsCount) : 0
                            HStack(spacing: 6) {
                                Text("\(star)").font(.omMicro).foregroundStyle(Color.omTextMuted).frame(width: 8)
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.omBgSunken)
                                        Capsule().fill(star >= 4 ? Color.sage500 : Color.omBorderStrong)
                                            .frame(width: geo.size.width * pct)
                                    }
                                }
                                .frame(height: 5)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(Spacing.l)
                .background(Color.omBgElevated)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))

                // Review list
                ForEach(data.reviews) { review in
                    reviewItem(review)
                    Divider()
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }

    private func reviewItem(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
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
        .padding(.vertical, Spacing.s)
    }

    private var aboutTab: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            if let date = sellerJoinedDate {
                Text("Member since \(date.formatted(.dateTime.month(.wide).year()))")
                    .font(.omBody).foregroundStyle(Color.omTextMuted)
            } else {
                Text("Member")
                    .font(.omBody).foregroundStyle(Color.omTextMuted)
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }

    private func loadSellerInfo() async {
        struct SellerInfo: Decodable {
            let name: String
            let createdAt: Date
            enum CodingKeys: String, CodingKey {
                case name
                case createdAt = "created_at"
            }
        }
        do {
            let info: SellerInfo = try await APIClient.shared.request("/users/\(sellerID)")
            sellerName = info.name
            sellerJoinedDate = info.createdAt
        } catch {}
    }

    private func toggleBlock() async {
        isTogglingBlock = true
        defer { isTogglingBlock = false }
        do {
            if isBlocked {
                try await BlockService.unblock(userID: sellerID)
                withAnimation(.easeInOut(duration: 0.3)) { isBlocked = false }
            } else {
                try await BlockService.block(userID: sellerID)
                withAnimation(.spring(response: 0.3)) { isBlocked = true }
            }
        } catch {}
    }
}
