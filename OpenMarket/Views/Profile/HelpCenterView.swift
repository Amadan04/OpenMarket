import SwiftUI

struct HelpCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedItem: String? = nil

    private let faqs: [(String, String)] = [
        ("How do I make an offer?",
         "Open any listing and tap \"Make an Offer\". Enter your amount and an optional note, then tap Send. The seller will be notified and can accept, decline, or counter your offer."),
        ("How do I list an item for sale?",
         "Tap the + button in the navigation bar from any screen. Add photos, a title, description, price, and location. Tap Post to publish your listing."),
        ("What happens when my offer is accepted?",
         "You'll receive a notification and a message from the seller. The listing is marked as sold and other pending offers are automatically cancelled. You can then arrange pickup or delivery directly with the seller."),
        ("How do I withdraw an offer?",
         "Open the product listing where you made an offer. Scroll to the offer section and tap Withdraw Offer. You can only withdraw offers that are still pending."),
        ("Can I edit my listing after posting?",
         "Yes. Go to Profile → My Listings, tap the listing you want to edit, and make your changes. You can update the title, price, description, photos, and location."),
        ("How do I mark an item as sold?",
         "Go to Profile → My Listings and tap the checkmark icon next to an active listing. You can optionally select which buyer you sold to, which helps with reviews."),
        ("Is my payment handled in the app?",
         "OpenMarket facilitates the connection between buyers and sellers. Payment and pickup are arranged directly between the two parties via the in-app chat."),
        ("How do I report a listing?",
         "Open the listing and tap the flag icon in the top right corner. Select the reason and submit. Our team reviews all reports within 24 hours."),
        ("How do I block a user?",
         "Open their profile by tapping their name on any listing. Tap the ⋯ button in the top right and select Block. Blocked users cannot message you and their listings will be hidden."),
    ]

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
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SUPPORT").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text("Help center").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.xl) {
                        // Contact banner
                        HStack(spacing: Spacing.m) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.omAccent)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Need more help?").font(.inter(14, weight: .semibold)).foregroundStyle(Color.omText)
                                Text("support@openmarket.bh")
                                    .font(.inter(13)).foregroundStyle(Color.omAccent)
                            }
                            Spacer()
                        }
                        .padding(Spacing.l)
                        .background(Color.omBgElevated)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))

                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("FREQUENTLY ASKED".uppercased())
                                .font(.omMicro).foregroundStyle(Color.omTextSubtle).padding(.leading, 4)

                            VStack(spacing: 0) {
                                ForEach(faqs, id: \.0) { q, a in
                                    faqRow(question: q, answer: a)
                                    if q != faqs.last?.0 { Divider().padding(.leading, Spacing.l) }
                                }
                            }
                            .background(Color.omBgElevated)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                            .overlay(RoundedRectangle(cornerRadius: Radius.lg).stroke(Color.omBorder, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func faqRow(question: String, answer: String) -> some View {
        let isExpanded = expandedItem == question
        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expandedItem = isExpanded ? nil : question
                }
            } label: {
                HStack(spacing: Spacing.m) {
                    Text(question)
                        .font(.inter(14, weight: .medium))
                        .foregroundStyle(Color.omText)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.omTextSubtle)
                }
                .padding(Spacing.l)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(answer)
                    .font(.inter(13))
                    .foregroundStyle(Color.omTextMuted)
                    .lineSpacing(4)
                    .padding(.horizontal, Spacing.l)
                    .padding(.bottom, Spacing.l)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
