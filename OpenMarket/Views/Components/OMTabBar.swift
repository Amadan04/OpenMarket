import SwiftUI

enum OMTab: Int, CaseIterable {
    case home, map, sell, messages, profile

    var label: String {
        switch self {
        case .home:     "Browse"
        case .map:      "Nearby"
        case .sell:     "Sell"
        case .messages: "Messages"
        case .profile:  "Me"
        }
    }

    var icon: String {
        switch self {
        case .home:     "house.fill"
        case .map:      "map.fill"
        case .sell:     "plus"
        case .messages: "bubble.left.and.bubble.right.fill"
        case .profile:  "person.fill"
        }
    }
}

struct OMTabBar: View {
    @Binding var selected: OMTab
    var onSell: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(OMTab.allCases, id: \.self) { tab in
                if tab == .sell {
                    // Center sell button
                    Button(action: onSell) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(Color.omAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: Color.omAccent.opacity(0.4), radius: 8, y: 4)
                    }
                    .frame(maxWidth: .infinity)
                    .offset(y: -8)
                } else {
                    Button { selected = tab } label: {
                        VStack(spacing: 3) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 22, weight: selected == tab ? .semibold : .regular))
                                .foregroundStyle(selected == tab ? Color.omAccent : Color.stone400)
                            Text(tab.label)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(selected == tab ? Color.omAccent : Color.stone400)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, Spacing.s)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, Spacing.s)
        .frame(height: 84)
        .padding(.bottom, Spacing.xl)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) { Color.omBorder.frame(height: 0.5) }
                .ignoresSafeArea()
        )
    }
}
