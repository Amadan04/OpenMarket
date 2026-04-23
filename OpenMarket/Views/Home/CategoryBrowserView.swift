import SwiftUI

struct CategoryBrowserView: View {
    @Environment(\.dismiss) private var dismiss

    private let items: [(String, String, Color)] = [
        ("Vehicles",    "🚗", Color(hex: "#E8D5B0")),
        ("Property",    "🏠", Color(hex: "#D5E8D5")),
        ("Mobile",      "📱", Color(hex: "#D5DCE8")),
        ("Electronics", "📷", Color(hex: "#E8D5D5")),
        ("Furniture",   "🪑", Color(hex: "#E8E0D5")),
        ("Fashion",     "👕", Color(hex: "#E0D5E8")),
        ("Sports",      "🚲", Color(hex: "#D5E8E0")),
        ("Books",       "📚", Color(hex: "#E8E8D5")),
        ("Other",       "📦", Color(hex: "#E8DCCC")),
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
                        Text("BROWSE").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text("Categories").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.m) {
                        ForEach(items, id: \.0) { name, emoji, color in
                            NavigationLink {
                                CategoryProductsView(category: name, emoji: emoji)
                            } label: {
                                VStack(spacing: Spacing.s) {
                                    Text(emoji).font(.system(size: 36))
                                    Text(name)
                                        .font(.inter(15, weight: .semibold))
                                        .foregroundStyle(Color.omText)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .background(color)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
