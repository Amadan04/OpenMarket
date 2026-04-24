import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProductListViewModel()
    @ObservedObject private var historyStore = SearchHistoryStore.shared
    @State private var query = ""
    @FocusState private var focused: Bool

    private let trending = ["Vintage camera", "Mid-century furniture", "Bikes under $500", "Plants", "Records"]

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Search bar row
                HStack(spacing: Spacing.m) {
                    HStack(spacing: Spacing.m) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Color.omTextMuted)
                        TextField("Search listings…", text: $query)
                            .font(.omCallout)
                            .foregroundStyle(Color.omText)
                            .focused($focused)
                            .submitLabel(.search)
                            .onSubmit { Task { await search() } }
                        if !query.isEmpty {
                            Button { query = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(Color.omTextSubtle)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.l)
                    .frame(height: 48)
                    .background(Color.omBgElevated)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.omBorder, lineWidth: 1))

                    Button("Cancel") { dismiss() }
                        .font(.inter(15, weight: .semibold))
                        .foregroundStyle(Color.omText)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                if viewModel.isLoading {
                    ScrollView {
                        LazyVStack(spacing: Spacing.m) {
                            ForEach(0..<6, id: \.self) { _ in SkeletonRowView() }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.m)
                    }
                } else if !viewModel.products.isEmpty {
                    // Results
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.products) { product in
                                NavigationLink { ProductDetailView(product: product) } label: {
                                    searchRow(product)
                                }
                                .buttonStyle(.plain)
                                Divider().padding(.leading, 88)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                    }
                } else {
                    // Browse state
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if !historyStore.terms.isEmpty {
                                sectionHeader("Recent")
                                ForEach(historyStore.terms, id: \.self) { term in
                                    recentRow(term)
                                }
                            }

                            sectionHeader("Trending nearby").padding(.top, Spacing.xxl)
                            FlowLayout(spacing: Spacing.s) {
                                ForEach(trending, id: \.self) { term in
                                    OMChip(label: term)
                                        .onTapGesture {
                                            query = term
                                            Task { await search() }
                                        }
                                }
                            }
                            .padding(.top, Spacing.s)
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { focused = true }
    }

    private func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        SearchHistoryStore.shared.record(trimmed)
        viewModel.searchText = trimmed
        await viewModel.applyFilters()
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.omMicro)
            .foregroundStyle(Color.omTextSubtle)
            .padding(.vertical, Spacing.m)
    }

    private func recentRow(_ term: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.m) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.omTextMuted)
                    .frame(width: 32, height: 32)
                    .background(Color.omBgSunken)
                    .clipShape(Circle())
                Text(term).font(.omCallout).foregroundStyle(Color.omText)
                Spacer()
                Button { SearchHistoryStore.shared.remove(term) } label: {
                    Image(systemName: "xmark").font(.system(size: 13)).foregroundStyle(Color.omTextSubtle)
                }
            }
            .padding(.vertical, Spacing.m)
            .contentShape(Rectangle())
            .onTapGesture {
                query = term
                Task { await search() }
            }
            Divider()
        }
    }

    private func searchRow(_ product: Product) -> some View {
        HStack(spacing: Spacing.m) {
            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Rectangle().fill(Color.cream200)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: Radius.sm))

            VStack(alignment: .leading, spacing: 2) {
                Text(product.title).font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText).lineLimit(1)
                Text(product.location).font(.inter(13)).foregroundStyle(Color.omTextMuted)
            }
            Spacer()
            Text(product.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                .font(.inter(15, weight: .bold))
                .foregroundStyle(Color.omAccent)
        }
        .padding(.vertical, Spacing.m)
    }
}

// Simple flow layout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: ProposedViewSize(bounds.size), subviews: subviews)
        for (idx, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[idx].x, y: bounds.minY + result.positions[idx].y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0; var y: CGFloat = 0; var rowH: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowH = max(rowH, size.height)
        }
        return (CGSize(width: maxWidth, height: y + rowH), positions)
    }
}
