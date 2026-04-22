import SwiftUI

// MARK: - Shimmer modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.2

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.45), location: 0.45),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .init(x: phase, y: 0.5),
                        endPoint: .init(x: phase + 0.8, y: 0.5)
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .allowsHitTesting(false)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    func shimmer() -> some View { modifier(ShimmerModifier()) }
}

// MARK: - Skeleton card (matches ProductCardView — 130 image + 76 text = 206pt)
struct SkeletonCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image area
            Color.omBgSunken
                .frame(height: 130)

            // Text area
            VStack(alignment: .leading, spacing: 6) {
                skeletonBar(width: .infinity, height: 10)
                skeletonBar(width: 100, height: 10)
                skeletonBar(width: 60, height: 9)
            }
            .padding(8)
            .frame(height: 76, alignment: .topLeading)
        }
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
        .shimmer()
    }

    private func skeletonBar(width: CGFloat, height: CGFloat) -> some View {
        Group {
            if width == .infinity {
                Color.omBgSunken.frame(maxWidth: .infinity).frame(height: height).clipShape(Capsule())
            } else {
                Color.omBgSunken.frame(width: width, height: height).clipShape(Capsule())
            }
        }
    }
}

// MARK: - Skeleton row (matches FavoritesView / MyListingsView rows)
struct SkeletonRowView: View {
    var body: some View {
        HStack(spacing: Spacing.m) {
            Color.omBgSunken
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))

            VStack(alignment: .leading, spacing: 8) {
                Color.omBgSunken.frame(width: 60, height: 8).clipShape(Capsule())
                Color.omBgSunken.frame(maxWidth: .infinity).frame(height: 10).clipShape(Capsule())
                Color.omBgSunken.frame(width: 80, height: 10).clipShape(Capsule())
            }
            Spacer()
        }
        .padding(Spacing.m)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
        .shimmer()
    }
}

// MARK: - Skeleton conversation row (matches ConversationsView rows)
struct SkeletonConversationRow: View {
    var body: some View {
        HStack(spacing: Spacing.m) {
            Circle()
                .fill(Color.omBgSunken)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Color.omBgSunken.frame(width: 120, height: 10).clipShape(Capsule())
                    Spacer()
                    Color.omBgSunken.frame(width: 40, height: 8).clipShape(Capsule())
                }
                Color.omBgSunken.frame(maxWidth: .infinity).frame(height: 9).clipShape(Capsule())
                Color.omBgSunken.frame(width: 160, height: 9).clipShape(Capsule())
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.m)
        .shimmer()
    }
}

// MARK: - 2-column skeleton grid (matches HomeView MasonryGrid)
struct SkeletonGrid: View {
    var count: Int = 6

    var body: some View {
        GeometryReader { geo in
            let colWidth = (geo.size.width - Spacing.m) / 2
            LazyVGrid(
                columns: [GridItem(.fixed(colWidth)), GridItem(.fixed(colWidth))],
                spacing: Spacing.m
            ) {
                ForEach(0..<count, id: \.self) { _ in
                    SkeletonCardView()
                        .frame(width: colWidth)
                }
            }
        }
        .frame(height: CGFloat(Int(ceil(Double(count) / 2))) * 220)
    }
}
