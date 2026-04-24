import SwiftUI

struct ReviewsView: View {
    let sellerID: Int
    @State private var reviewsResponse: ReviewsResponse?
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
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
                    Text("Reviews").font(.serif(28)).foregroundStyle(Color.omText)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                if isLoading {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(0..<5, id: \.self) { _ in SkeletonRowView() }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.m)
                    }
                } else if let data = reviewsResponse {
                    ScrollView {
                        VStack(spacing: Spacing.l) {
                            // Summary card
                            HStack(spacing: Spacing.xl) {
                                VStack(spacing: 6) {
                                    Text(String(format: "%.1f", data.averageRating))
                                        .font(.serif(44)).foregroundStyle(Color.omText)
                                    StarRatingView(rating: data.averageRating, size: 12)
                                    Text("\(data.reviewsCount) reviews").font(.inter(11)).foregroundStyle(Color.omTextMuted)
                                }
                                VStack(spacing: 4) {
                                    ForEach([5,4,3,2,1], id: \.self) { star in
                                        let pct = data.reviewsCount > 0 ?
                                            Double(data.reviews.filter { $0.rating == star }.count) / Double(data.reviewsCount) : 0.0
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
                                VStack(alignment: .leading, spacing: Spacing.m) {
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
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }
                } else {
                    Spacer()
                    Text("No reviews yet").font(.omBody).foregroundStyle(Color.omTextMuted)
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            isLoading = true
            reviewsResponse = try? await ReviewService.getReviews(forSellerID: sellerID)
            isLoading = false
        }
    }
}
