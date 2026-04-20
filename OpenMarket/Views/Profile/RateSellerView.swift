import SwiftUI

struct RateSellerView: View {
    let sellerID: Int
    let sellerName: String
    var product: Product? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var rating = 4
    @State private var comment = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let tags = ["Quick to respond", "Item as described", "Friendly", "Easy pickup", "Fair price", "On time"]
    @State private var selectedTags: Set<String> = ["Quick to respond", "Item as described", "Friendly"]

    private var ratingLabel: String {
        switch rating {
        case 1: "Poor"
        case 2: "Fair"
        case 3: "Okay"
        case 4: "Great"
        default: "Excellent!"
        }
    }

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Nav
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
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("LEAVE A REVIEW").font(.omMicro).foregroundStyle(Color.omTextMuted)
                            Text("How was your experience with \(sellerName)?")
                                .font(.serif(30))
                                .foregroundStyle(Color.omText)
                        }

                        // Product card (if provided)
                        if let p = product {
                            HStack(spacing: Spacing.m) {
                                AsyncImage(url: URL(string: p.images.first ?? "")) { phase in
                                    switch phase {
                                    case .success(let img): img.resizable().scaledToFill()
                                    default: Rectangle().fill(Color.cream200)
                                    }
                                }
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(p.title).font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText)
                                    Text("Recently").font(.inter(12)).foregroundStyle(Color.omTextMuted)
                                }
                                Spacer()
                                Text(p.price.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                                    .font(.inter(14, weight: .bold)).foregroundStyle(Color.omAccent)
                            }
                            .padding(Spacing.m)
                            .background(Color.omBgElevated)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                            .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                        }

                        // Star picker
                        VStack(spacing: Spacing.m) {
                            StarPickerView(rating: $rating)
                            Text(ratingLabel)
                                .font(.serif(22))
                                .foregroundStyle(Color.omText)
                                .animation(.spring(response: 0.4, dampingFraction: 0.78), value: rating)
                        }
                        .frame(maxWidth: .infinity)

                        // Tag picker
                        VStack(alignment: .leading, spacing: Spacing.m) {
                            Text("WHAT WENT WELL?").font(.omMicro).foregroundStyle(Color.omTextSubtle)
                            FlowLayout(spacing: Spacing.s) {
                                ForEach(tags, id: \.self) { tag in
                                    let active = selectedTags.contains(tag)
                                    HStack(spacing: 4) {
                                        if active { Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)) }
                                        Text(tag)
                                    }
                                    .font(.inter(13, weight: .medium))
                                    .foregroundStyle(active ? .white : Color.omText)
                                    .padding(.horizontal, Spacing.m)
                                    .frame(height: 32)
                                    .background(active ? Color.omAccent : Color.omBgElevated)
                                    .clipShape(Capsule())
                                    .overlay(active ? nil : Capsule().stroke(Color.omBorder, lineWidth: 1))
                                    .onTapGesture {
                                        if selectedTags.contains(tag) { selectedTags.remove(tag) }
                                        else { selectedTags.insert(tag) }
                                    }
                                }
                            }
                        }

                        // Comment
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: Radius.md)
                                .fill(Color.omBgElevated)
                                .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Share details (optional)").font(.inter(12, weight: .medium)).foregroundStyle(Color.omTextMuted)
                                TextEditor(text: $comment)
                                    .font(.inter(15))
                                    .foregroundStyle(Color.omText)
                                    .frame(minHeight: 80)
                                    .scrollContentBackground(.hidden)
                            }
                            .padding(Spacing.l)
                        }
                        .frame(minHeight: 120)

                        if let err = errorMessage {
                            Text(err).font(.omCaption).foregroundStyle(Color.omDanger)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                }

                // Submit
                OMButton(label: "Submit review", size: .lg, fullWidth: true, isLoading: isLoading) {
                    Task { await submit() }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)
                .background(Color.omBg)
                .overlay(alignment: .top) { Color.omBorder.frame(height: 1) }
            }
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            _ = try await ReviewService.addReview(sellerID: sellerID, rating: rating, comment: comment)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
