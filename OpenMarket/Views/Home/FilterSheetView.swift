import SwiftUI

struct FilterSheetView: View {
    @ObservedObject var viewModel: ProductListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var minPriceText = ""
    @State private var maxPriceText = ""
    @State private var radiusEnabled = false
    @State private var radiusKm: Double = 10

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 0) {
                // Grabber
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5)
                    .padding(.top, Spacing.s)
                    .padding(.bottom, Spacing.m)

                // Header
                HStack {
                    Button("Reset") {
                        viewModel.resetFilters()
                        minPriceText = ""; maxPriceText = ""
                        radiusEnabled = false; radiusKm = 10
                    }
                    .font(.inter(14, weight: .semibold))
                    .foregroundStyle(Color.omTextMuted)

                    Spacer()
                    Text("Filters").font(.serif(22)).foregroundStyle(Color.omText)
                    Spacer()

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(width: 30, height: 30)
                            .background(Color.omBgSunken)
                            .clipShape(Circle())
                            .foregroundStyle(Color.omText)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.l)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Price
                        filterSection("Price") {
                            HStack(spacing: Spacing.m) {
                                OMField(label: "Min", text: $minPriceText, placeholder: "BD 0")
                                    .keyboardType(.decimalPad)
                                OMField(label: "Max", text: $maxPriceText, placeholder: "Any")
                                    .keyboardType(.decimalPad)
                            }
                        }

                        // Category
                        filterSection("Category") {
                            FlowLayout(spacing: Spacing.s) {
                                ForEach(Constants.Categories.all, id: \.self) { cat in
                                    OMChip(label: cat, active: viewModel.selectedCategory == cat)
                                        .onTapGesture { viewModel.selectedCategory = cat }
                                }
                            }
                        }

                        // Condition
                        filterSection("Condition") {
                            FlowLayout(spacing: Spacing.s) {
                                ForEach(["Any", "New", "Like New", "Good", "Fair"], id: \.self) { cond in
                                    OMChip(label: cond, active: viewModel.selectedCondition == cond)
                                        .onTapGesture { viewModel.selectedCondition = cond }
                                }
                            }
                        }

                        // Distance
                        filterSection("Distance") {
                            VStack(spacing: Spacing.m) {
                                Toggle(isOn: $radiusEnabled) {
                                    HStack(spacing: Spacing.s) {
                                        Image(systemName: "location.fill").foregroundStyle(Color.omAccent)
                                        Text("Filter by distance").font(.omCallout).foregroundStyle(Color.omText)
                                    }
                                }
                                .tint(Color.omAccent)
                                .onChange(of: radiusEnabled) { _, on in
                                    if on { LocationService.shared.requestPermission() }
                                }

                                if radiusEnabled {
                                    VStack(spacing: Spacing.s) {
                                        HStack {
                                            Text("Within").font(.inter(13)).foregroundStyle(Color.omTextMuted)
                                            Spacer()
                                            Text("\(Int(radiusKm)) km")
                                                .font(.inter(14, weight: .bold))
                                                .foregroundStyle(Color.omAccent)
                                        }
                                        Slider(value: $radiusKm, in: 1...100, step: 1)
                                            .tint(Color.omAccent)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .animation(.spring(response: 0.3), value: radiusEnabled)
                        }

                        // Sort
                        filterSection("Sort by") {
                            VStack(spacing: 0) {
                                ForEach(["Newest", "Price: low to high", "Price: high to low"], id: \.self) { opt in
                                    HStack {
                                        Text(opt).font(.omBody).foregroundStyle(Color.omText)
                                        Spacer()
                                        if opt == "Newest" {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.omAccent)
                                        }
                                    }
                                    .padding(.vertical, Spacing.m)
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }

                // Apply button
                VStack {
                    OMButton(label: "Show results", size: .lg, fullWidth: true) {
                        viewModel.minPrice = Double(minPriceText)
                        viewModel.maxPrice = Double(maxPriceText)
                        viewModel.radiusKm = radiusEnabled ? radiusKm : nil
                        Task { await viewModel.applyFilters() }
                        dismiss()
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .background(Color.omBg)
                .overlay(alignment: .top) { Color.omBorder.frame(height: 1) }
            }
            .background(Color.omBg)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(.bottom, Spacing.xl)
        }
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    private func filterSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(title.uppercased())
                .font(.omMicro)
                .foregroundStyle(Color.omTextSubtle)
                .padding(.top, Spacing.l)
            content()
        }
    }
}
