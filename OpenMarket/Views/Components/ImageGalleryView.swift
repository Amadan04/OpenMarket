import SwiftUI

// MARK: - Full-screen swipe/zoom gallery

struct ImageGalleryView: View {
    let images: [String]
    @Binding var currentIndex: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { idx, url in
                    ZoomableImageView(url: url)
                        .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Top bar
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(.black.opacity(0.55))
                            .clipShape(Circle())
                    }
                    Spacer()
                    if images.count > 1 {
                        Text("\(currentIndex + 1) / \(images.count)")
                            .font(.inter(14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(.black.opacity(0.55))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.top, 56)
                Spacer()
            }

            // Page dots
            if images.count > 1 {
                HStack(spacing: 5) {
                    ForEach(0..<images.count, id: \.self) { i in
                        Capsule()
                            .fill(.white.opacity(i == currentIndex ? 1 : 0.4))
                            .frame(width: i == currentIndex ? 20 : 6, height: 6)
                    }
                }
                .padding(.bottom, Spacing.xl)
            }
        }
        .statusBarHidden(true)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Per-image pinch + pan view

struct ZoomableImageView: View {
    let url: String

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var steadyOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero

    private var totalOffset: CGSize {
        CGSize(width: steadyOffset.width + dragOffset.width,
               height: steadyOffset.height + dragOffset.height)
    }

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let img):
                img.resizable().scaledToFit()
            case .failure:
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray)
            default:
                ProgressView().tint(.white)
            }
        }
        .scaleEffect(scale)
        .offset(totalOffset)
        .gesture(pinchGesture)
        .onTapGesture(count: 2) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                if scale > 1 { resetZoom() } else { scale = 2.5 }
            }
        }
        // Pan overlay — only active when zoomed, so TabView can swipe when scale == 1
        .overlay {
            if scale > 1 {
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(panGesture)
            }
        }
    }

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { val in
                let delta = val / lastScale
                lastScale = val
                scale = min(max(scale * delta, 1), 5)
            }
            .onEnded { _ in
                lastScale = 1
                if scale < 1.05 {
                    withAnimation(.spring(response: 0.3)) { resetZoom() }
                }
            }
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { val in dragOffset = val.translation }
            .onEnded { val in
                steadyOffset = CGSize(
                    width: steadyOffset.width + val.translation.width,
                    height: steadyOffset.height + val.translation.height
                )
                dragOffset = .zero
            }
    }

    private func resetZoom() {
        scale = 1; lastScale = 1; steadyOffset = .zero; dragOffset = .zero
    }
}
