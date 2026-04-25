import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    private let sections: [(String, String)] = [
        ("Acceptance", "By using OpenMarket, you agree to these terms. If you do not agree, please discontinue use of the app. We may update these terms periodically and will notify you of significant changes."),
        ("User accounts", "You must be 18 years or older to create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account."),
        ("Listings", "You may only list items you own or have the right to sell. Prohibited items include stolen goods, counterfeit products, weapons, drugs, and any item illegal under Bahraini law. OpenMarket reserves the right to remove any listing at any time."),
        ("Transactions", "OpenMarket is a platform connecting buyers and sellers. We do not handle payments, shipping, or physical delivery. All transactions are conducted directly between users. We are not responsible for disputes between parties."),
        ("Offers", "Making an offer constitutes a binding intent to purchase at the stated price if accepted. Sellers are not obligated to accept any offer. Both parties should communicate clearly before finalising a transaction."),
        ("Reviews", "Reviews must be honest and based on genuine transactions. Fake, misleading, or defamatory reviews will be removed. Repeated abuse of the review system may result in account suspension."),
        ("Privacy", "We collect only the information necessary to operate the service. Location data is used to show nearby listings and is never sold to third parties. You can manage your privacy settings in the app."),
        ("Liability", "OpenMarket is provided as-is. We make no warranties regarding the accuracy of listings or the conduct of users. Our liability is limited to the maximum extent permitted by Bahraini law."),
        ("Governing law", "These terms are governed by the laws of the Kingdom of Bahrain. Any disputes shall be subject to the exclusive jurisdiction of the courts of Bahrain."),
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
                        Text("LEGAL").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text("Terms & privacy").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                // Tab switcher
                HStack(spacing: 0) {
                    ForEach([(0, "Terms of use"), (1, "Privacy policy")], id: \.0) { i, label in
                        Button {
                            withAnimation { selectedTab = i }
                        } label: {
                            VStack(spacing: Spacing.s) {
                                Text(label).font(.inter(14, weight: .semibold))
                                    .foregroundStyle(selectedTab == i ? Color.omText : Color.omTextMuted)
                                Rectangle()
                                    .fill(selectedTab == i ? Color.omAccent : Color.clear)
                                    .frame(height: 2)
                            }
                            .padding(.vertical, Spacing.m)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                Divider()

                ScrollView {
                    if selectedTab == 0 {
                        termsContent
                    } else {
                        privacyContent
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var termsContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            Text("Last updated: January 2025")
                .font(.inter(12)).foregroundStyle(Color.omTextMuted)

            ForEach(sections, id: \.0) { title, body in
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text(title).font(.inter(15, weight: .bold)).foregroundStyle(Color.omText)
                    Text(body).font(.inter(14)).foregroundStyle(Color.omTextMuted).lineSpacing(4)
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.l)
        .padding(.bottom, Spacing.xl)
    }

    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            Text("Last updated: January 2025")
                .font(.inter(12)).foregroundStyle(Color.omTextMuted)

            ForEach([
                ("Data we collect", "Account information (name and email), device identifiers, approximate location when using the map feature, messages between users, and usage analytics."),
                ("How we use your data", "To operate the marketplace, match buyers and sellers, send notifications, prevent fraud, and improve the service. We do not sell your personal data."),
                ("Data sharing", "We share data only as required to operate the service (e.g., push notification services). We may disclose data if required by Bahraini law enforcement."),
                ("Data retention", "Account data is retained while your account is active. You may request deletion by contacting support. Some data may be retained for legal compliance purposes."),
                ("Your rights", "You have the right to access, correct, or delete your personal data. Contact support@openmarket.bh to exercise these rights."),
                ("Cookies & tracking", "The app uses local storage for session management. We do not use third-party advertising cookies."),
                ("Children", "OpenMarket is not intended for users under 18. We do not knowingly collect data from minors."),
                ("Contact", "For privacy enquiries, email privacy@openmarket.bh or write to OpenMarket, Manama, Kingdom of Bahrain."),
            ], id: \.0) { title, body in
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text(title).font(.inter(15, weight: .bold)).foregroundStyle(Color.omText)
                    Text(body).font(.inter(14)).foregroundStyle(Color.omTextMuted).lineSpacing(4)
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.l)
        .padding(.bottom, Spacing.xl)
    }
}
