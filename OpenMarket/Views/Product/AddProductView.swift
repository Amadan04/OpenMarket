import SwiftUI
import PhotosUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var step = 1
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var showLocationPicker = false
    private let totalSteps = 4

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.omBg.ignoresSafeArea()
                VStack(spacing: 0) {
                    addHeader
                    stepContent
                    addFooter
                }
                if viewModel.draftSaved {
                    Text("Draft saved")
                        .font(.inter(14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.l)
                        .padding(.vertical, Spacing.s)
                        .background(Color.omAccent)
                        .clipShape(Capsule())
                        .padding(.top, Spacing.xl)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.draftSaved)
                }
            }
            .navigationBarHidden(true)
            .onChange(of: viewModel.didSubmit) { _, submitted in
                if submitted { dismiss() }
            }
        }
    }

    // MARK: - Header
    private var addHeader: some View {
        VStack(spacing: Spacing.m) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.omText)
                        .frame(width: 40, height: 40)
                        .background(Color.omBgElevated)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                }
                Spacer()
                Text("Step \(step) of \(totalSteps)")
                    .font(.omMicro)
                    .foregroundStyle(Color.omTextMuted)
                Spacer()
                Button("Save draft") { viewModel.saveDraft() }
                    .font(.inter(14, weight: .semibold))
                    .foregroundStyle(Color.omTextMuted)
            }
            .padding(.horizontal, Spacing.l)

            Text(stepTitle)
                .font(.serif(30))
                .foregroundStyle(Color.omText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.xl)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.omBgSunken).frame(height: 4)
                    RoundedRectangle(cornerRadius: 2).fill(Color.omAccent)
                        .frame(width: geo.size.width * CGFloat(step) / CGFloat(totalSteps), height: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.78), value: step)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, Spacing.l)
        }
        .padding(.vertical, Spacing.m)
    }

    private var stepTitle: String {
        switch step {
        case 1: "Add photos"
        case 2: "Describe it"
        case 3: "Set price & place"
        default: "Review & post"
        }
    }

    // MARK: - Step content
    @ViewBuilder private var stepContent: some View {
        switch step {
        case 1: photosStep
        case 2: detailsStep
        case 3: priceStep
        default: reviewStep
        }
    }

    // Step 1: Photos
    private var photosStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("First photo is the cover. Add up to 10.")
                    .font(.inter(14))
                    .foregroundStyle(Color.omTextMuted)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.m) {
                    ForEach(Array(viewModel.images.enumerated()), id: \.offset) { idx, img in
                        ZStack(alignment: .topLeading) {
                            Image(uiImage: img)
                                .resizable().scaledToFill()
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                            if idx == 0 {
                                Text("COVER")
                                    .font(.omMicro).foregroundStyle(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Color.omAccent)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .padding(8)
                            }
                            Button {
                                viewModel.images.remove(at: idx)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .shadow(radius: 2)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(6)
                        }
                        .frame(height: 100)
                    }

                    if viewModel.images.count < 10 {
                        PhotosPicker(
                            selection: $pickerItems,
                            maxSelectionCount: 10 - viewModel.images.count,
                            matching: .images
                        ) {
                            RoundedRectangle(cornerRadius: Radius.md)
                                .strokeBorder(Color.omBorderStrong, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                .frame(height: 100)
                                .overlay(
                                    VStack(spacing: 4) {
                                        Image(systemName: "plus").font(.title3).foregroundStyle(Color.omTextMuted)
                                        Text("Add photos").font(.inter(11)).foregroundStyle(Color.omTextMuted)
                                    }
                                )
                        }
                        .onChange(of: pickerItems) { _, items in
                            Task {
                                for item in items {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let img = UIImage(data: data) {
                                        viewModel.images.append(img)
                                    }
                                }
                                pickerItems = []
                            }
                        }
                    }
                }

                HStack(spacing: Spacing.m) {
                    Text("💡").font(.title3)
                        .frame(width: 32, height: 32)
                        .background(.white)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Good photos sell faster").font(.inter(13, weight: .semibold)).foregroundStyle(Color.omText)
                        Text("Use natural light and a clean background. Show any wear honestly.")
                            .font(.inter(12)).foregroundStyle(Color.omTextMuted).lineSpacing(3)
                    }
                }
                .padding(Spacing.m)
                .background(Color.sage100)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
    }

    // Step 2: Details
    private var detailsStep: some View {
        ScrollView {
            VStack(spacing: Spacing.m) {
                OMField(label: "Title", text: $viewModel.title, placeholder: "e.g. Vintage leather jacket")
                // Description textarea
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Color.omBgElevated)
                        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.inter(12, weight: .medium))
                            .foregroundStyle(Color.omTextMuted)
                        TextEditor(text: $viewModel.description)
                            .font(.inter(15))
                            .foregroundStyle(Color.omText)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                        HStack {
                            Spacer()
                            Text("\(viewModel.description.count) / 500")
                                .font(.omMicro).foregroundStyle(Color.omTextSubtle)
                        }
                    }
                    .padding(Spacing.l)
                }
                .frame(minHeight: 130)

                // Category
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text("CATEGORY").font(.omMicro).foregroundStyle(Color.omTextSubtle)
                    FlowLayout(spacing: Spacing.s) {
                        ForEach(Constants.Categories.all.filter { $0 != "All" }, id: \.self) { cat in
                            OMChip(label: cat, active: viewModel.category == cat)
                                .onTapGesture { viewModel.category = cat }
                        }
                    }
                }

                // Condition segmented
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text("CONDITION").font(.omMicro).foregroundStyle(Color.omTextSubtle)
                    HStack(spacing: 2) {
                        ForEach(["New", "Like new", "Good", "Fair"], id: \.self) { cond in
                            let active = viewModel.condition == cond
                            Text(cond)
                                .font(.inter(13, weight: .semibold))
                                .foregroundStyle(active ? .white : Color.omText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.m)
                                .background(active ? Color.omAccent : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                                .onTapGesture { viewModel.condition = cond }
                        }
                    }
                    .padding(4)
                    .background(Color.omBgElevated)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
    }

    // Step 3: Price + Location
    private var priceStep: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                // Big price input
                VStack(spacing: Spacing.s) {
                    Text("YOUR PRICE").font(.omMicro).foregroundStyle(Color.omTextMuted)
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text("BHD").font(.inter(16, weight: .semibold)).foregroundStyle(Color.omTextMuted).padding(.trailing, 6)
                        TextField("0", text: $viewModel.price)
                            .font(.serif(64))
                            .foregroundStyle(Color.omText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 200)
                    }
                    // Price hint
                    Text("📈 Similar items sell for $50–$500")
                        .font(.inter(12, weight: .semibold))
                        .foregroundStyle(Color.sage700)
                        .padding(.horizontal, Spacing.m).padding(.vertical, 6)
                        .background(Color.sage100)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.xl)
                .background(Color.omBgElevated)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))

                OMField(label: "Location", text: $viewModel.location, placeholder: "City, neighbourhood", leadingIcon: "mappin.circle.fill")

                Button {
                    showLocationPicker = true
                } label: {
                    HStack(spacing: Spacing.s) {
                        Image(systemName: "map.fill").font(.system(size: 14))
                        Text("Pick on map")
                            .font(.inter(14, weight: .semibold))
                    }
                    .foregroundStyle(Color.omAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.omAccentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                }
                .sheet(isPresented: $showLocationPicker) {
                    LocationPickerView { coordinate, name in
                        viewModel.location = name
                        viewModel.latitude = coordinate.latitude
                        viewModel.longitude = coordinate.longitude
                    }
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
    }

    // Step 4: Review
    private var reviewStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("Everything look right?")
                    .font(.inter(16)).foregroundStyle(Color.omTextMuted)

                Group {
                    reviewRow(icon: "tag", label: "Title", value: viewModel.title.isEmpty ? "—" : viewModel.title)
                    reviewRow(icon: "dollarsign.circle", label: "Price", value: viewModel.price.isEmpty ? "—" : "$\(viewModel.price)")
                    reviewRow(icon: "folder", label: "Category", value: viewModel.category)
                    reviewRow(icon: "mappin", label: "Location", value: viewModel.location.isEmpty ? "—" : viewModel.location)
                }

                if let err = viewModel.errorMessage {
                    Text(err).font(.omCaption).foregroundStyle(Color.omDanger)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
    }

    private func reviewRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: icon).font(.system(size: 18)).foregroundStyle(Color.omAccent)
                .frame(width: 40, height: 40).background(Color.omAccentSoft).clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.omCaption).foregroundStyle(Color.omTextMuted)
                Text(value).font(.omBodyMed).foregroundStyle(Color.omText)
            }
            Spacer()
        }
        .padding(Spacing.m)
        .background(Color.omBgElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
    }

    // MARK: - Footer
    private var addFooter: some View {
        HStack(spacing: Spacing.m) {
            if step > 1 {
                OMButton(label: "Back", variant: .secondary, size: .lg) { step -= 1 }
            }
            OMButton(
                label: step == totalSteps ? "Post listing" : "Next",
                size: .lg,
                fullWidth: true,
                isLoading: viewModel.isLoading
            ) {
                if step < totalSteps {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) { step += 1 }
                } else {
                    Task { await viewModel.submit() }
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.m)
        .background(Color.omBg)
        .overlay(alignment: .top) { Color.omBorder.frame(height: 1) }
    }
}
