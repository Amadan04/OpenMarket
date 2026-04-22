import SwiftUI

struct ReportListingView: View {
    let productTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: String? = nil
    @State private var details = ""
    @State private var submitted = false

    private let reasons = [
        "Scam or fraud",
        "Prohibited item",
        "Misleading description",
        "Wrong category",
        "Offensive content",
        "Already sold",
        "Other"
    ]

    var body: some View {
        ZStack {
            Color.omBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.omBorderStrong)
                    .frame(width: 40, height: 5)
                    .padding(.top, Spacing.m)

                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.omText)
                            .frame(width: 32, height: 32)
                            .background(Color.omBgSunken)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Report listing").font(.inter(16, weight: .bold)).foregroundStyle(Color.omText)
                    Spacer()
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.m)
                .padding(.bottom, Spacing.m)

                if submitted {
                    // Confirmation
                    VStack(spacing: Spacing.l) {
                        Spacer()
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.omOk)
                        Text("Report submitted").font(.serif(24)).foregroundStyle(Color.omText)
                        Text("Thanks for keeping OpenMarket safe. We'll review this listing within 24 hours.")
                            .font(.omBody)
                            .foregroundStyle(Color.omTextMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.x4)
                        Spacer()
                        OMButton(label: "Done", size: .lg, fullWidth: true) { dismiss() }
                            .padding(.horizontal, Spacing.xl)
                            .padding(.bottom, Spacing.xl)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Spacing.l) {
                            // Listing name
                            Text(""\(productTitle)"")
                                .font(.inter(14, weight: .semibold))
                                .foregroundStyle(Color.omTextMuted)
                                .lineLimit(1)

                            // Reasons
                            VStack(alignment: .leading, spacing: Spacing.s) {
                                Text("Reason".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                                VStack(spacing: 0) {
                                    ForEach(reasons, id: \.self) { reason in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedReason = reason
                                            }
                                        } label: {
                                            HStack {
                                                Text(reason).font(.omBody).foregroundStyle(Color.omText)
                                                Spacer()
                                                Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                                    .foregroundStyle(selectedReason == reason ? Color.omAccent : Color.omBorderStrong)
                                            }
                                            .padding(.vertical, Spacing.m)
                                        }
                                        .buttonStyle(.plain)
                                        if reason != reasons.last { Divider() }
                                    }
                                }
                                .padding(.horizontal, Spacing.l)
                                .background(Color.omBgElevated)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                            }

                            // Details
                            VStack(alignment: .leading, spacing: Spacing.s) {
                                Text("Additional details (optional)".uppercased()).font(.omMicro).foregroundStyle(Color.omTextSubtle)
                                TextField("Describe the issue…", text: $details, axis: .vertical)
                                    .font(.omCallout)
                                    .foregroundStyle(Color.omText)
                                    .lineLimit(4)
                                    .padding(Spacing.m)
                                    .background(Color.omBgElevated)
                                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                                    .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }

                    VStack {
                        OMButton(
                            label: "Submit Report",
                            size: .lg,
                            fullWidth: true,
                            icon: "flag.fill"
                        ) {
                            withAnimation(.spring(response: 0.4)) { submitted = true }
                        }
                        .disabled(selectedReason == nil)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.m)
                    .background(Color.omBg)
                    .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
                }
            }
        }
        .animation(.spring(response: 0.4), value: submitted)
        .presentationDetents([.large])
    }
}
