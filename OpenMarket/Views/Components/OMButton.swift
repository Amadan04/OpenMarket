import SwiftUI

enum OMButtonVariant { case primary, secondary, ghost, dark }
enum OMButtonSize { case sm, md, lg }

struct OMButton: View {
    let label: String
    var variant: OMButtonVariant = .primary
    var size: OMButtonSize = .md
    var fullWidth: Bool = false
    var icon: String? = nil
    var isLoading: Bool = false
    let action: () -> Void

    private var height: CGFloat { switch size { case .sm: 36; case .md: 48; case .lg: 56 } }
    private var hPad: CGFloat   { switch size { case .sm: 14; case .md: 20; case .lg: 24 } }
    private var fontSize: CGFloat { switch size { case .sm: 14; case .md: 15; case .lg: 16 } }

    private var bg: Color {
        switch variant {
        case .primary:   .omAccent
        case .secondary: .omBgElevated
        case .ghost:     .clear
        case .dark:      .stone700
        }
    }
    private var fg: Color {
        switch variant {
        case .primary, .dark: .white
        case .secondary, .ghost: .omText
        }
    }
    private var border: Color? {
        switch variant {
        case .secondary: .omBorderStrong
        default: nil
        }
    }

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                if isLoading {
                    ProgressView().tint(fg)
                } else {
                    if let icon { Image(systemName: icon).font(.system(size: fontSize, weight: .semibold)) }
                    Text(label).font(.inter(fontSize, weight: .semibold)).kerning(-0.1)
                }
            }
            .foregroundStyle(fg)
            .frame(height: height)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, hPad)
            .background(bg)
            .clipShape(Capsule())
            .overlay(border.map { Capsule().stroke($0, lineWidth: 1) })
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {} onPressingChanged: { isPressing in
            pressed = isPressing
        }
    }
}
