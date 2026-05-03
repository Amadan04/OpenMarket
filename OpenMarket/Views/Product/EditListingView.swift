import SwiftUI

struct EditListingView: View {
    let product: Product
    var onDelete: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var price: String
    @State private var category: String
    @State private var condition: String
    @State private var location: String
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showDeleteConfirm = false
    @State private var saved = false
    @State private var errorMessage: String?

    private let conditions = ["New", "Like New", "Good", "Fair"]
    private let categories = Constants.Categories.all.filter { $0 != "All" }

    init(product: Product, onDelete: (() -> Void)? = nil) {
        self.product = product
        self.onDelete = onDelete
        _title       = State(initialValue: product.title)
        _description = State(initialValue: product.description)
        _price       = State(initialValue: String(format: "%.0f", product.price))
        _category    = State(initialValue: product.category)
        _condition   = State(initialValue: product.condition.isEmpty ? "Good" : product.condition)
        _location    = State(initialValue: product.location)
    }

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 36, height: 36)
                            .background(Color.omBgElevated)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.omBorder, lineWidth: 1))
                    }
                    Spacer()
                    Text("Edit listing").font(.inter(16, weight: .semibold)).foregroundStyle(Color.omText)
                    Spacer()
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView().scaleEffect(0.8).frame(width: 36, height: 36)
                        } else {
                            Text("Save")
                                .font(.inter(14, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, Spacing.m)
                                .padding(.vertical, 8)
                                .background(canSave ? Color.omAccent : Color.omBorderStrong)
                                .clipShape(Capsule())
                        }
                    }
                    .disabled(!canSave || isSaving)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .overlay(alignment: .bottom) { Color.omBorder.frame(height: 0.5) }

                ScrollView {
                    VStack(spacing: Spacing.l) {
                        // Stats row
                        HStack(spacing: 0) {
                            statCell(value: "\(product.viewCount)", label: "Views", icon: "eye")
                            Divider().frame(height: 36)
                            statCell(value: product.condition.isEmpty ? "—" : product.condition, label: "Condition", icon: "sparkles")
                            Divider().frame(height: 36)
                            statCell(value: product.isSold ? "Sold" : "Active", label: "Status", icon: "circle.fill")
                        }
                        .padding(.vertical, Spacing.m)
                        .background(Color.omBgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))

                        // Title
                        OMField(label: "Title", text: $title, placeholder: "What are you selling?", leadingIcon: "tag")

                        // Description
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Description").font(.omCaption).foregroundStyle(Color.omTextMuted)
                            TextEditor(text: $description)
                                .font(.omCallout)
                                .foregroundStyle(Color.omText)
                                .frame(minHeight: 100)
                                .padding(Spacing.m)
                                .background(Color.omBgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                        }

                        // Price
                        OMField(label: "Price (BHD)", text: $price, placeholder: "0", leadingIcon: "dollarsign.circle")
                            .keyboardType(.decimalPad)

                        // Category
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Category".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: Spacing.s) {
                                    ForEach(categories, id: \.self) { cat in
                                        OMChip(label: cat, active: category == cat)
                                            .onTapGesture { category = cat }
                                    }
                                }
                            }
                        }

                        // Condition
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Condition".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                            HStack(spacing: Spacing.s) {
                                ForEach(conditions, id: \.self) { cond in
                                    OMChip(label: cond, active: condition == cond)
                                        .onTapGesture { condition = cond }
                                }
                            }
                        }

                        // Location
                        OMField(label: "Location", text: $location, placeholder: "City or area", leadingIcon: "mappin.circle")

                        if let err = errorMessage {
                            HStack(spacing: Spacing.s) {
                                Image(systemName: "exclamationmark.circle.fill").foregroundStyle(Color.omError)
                                Text(err).font(.inter(13)).foregroundStyle(Color.omError)
                            }
                            .padding(Spacing.m)
                            .background(Color.omError.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        }

                        // Delete button
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            HStack(spacing: Spacing.s) {
                                if isDeleting {
                                    ProgressView().scaleEffect(0.8).tint(Color.omDanger)
                                } else {
                                    Image(systemName: "trash")
                                }
                                Text("Delete listing")
                            }
                            .font(.inter(15, weight: .semibold))
                            .foregroundStyle(Color.omDanger)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.m)
                            .background(Color.omDanger.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                            .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omDanger.opacity(0.2), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(isDeleting)

                        if saved {
                            HStack(spacing: Spacing.s) {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.omOk)
                                Text("Listing updated!").font(.inter(14, weight: .semibold)).foregroundStyle(Color.omOk)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.l)
                    .animation(.spring(response: 0.35), value: saved)
                }
            }
        }
        .navigationBarHidden(true)
        .confirmationDialog("Delete this listing?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { Task { await deleteProduct() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }

    private func statCell(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.omAccent)
            Text(value)
                .font(.inter(15, weight: .bold))
                .foregroundStyle(Color.omText)
            Text(label)
                .font(.omMicro)
                .foregroundStyle(Color.omTextMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(price) != nil
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            let body = CreateProductRequest(
                title: title.trimmingCharacters(in: .whitespaces),
                description: description,
                price: Double(price) ?? product.price,
                category: category,
                condition: condition,
                location: location,
                images: product.images,
                latitude: product.latitude,
                longitude: product.longitude
            )
            _ = try await ProductService.update(id: product.id, body: body)
            withAnimation(.spring(response: 0.4)) { saved = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteProduct() async {
        isDeleting = true
        do {
            try await ProductService.delete(id: product.id)
            onDelete?()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isDeleting = false
    }
}
