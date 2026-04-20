import SwiftUI

struct AvatarView: View {
    var initial: String = "?"
    var size: CGFloat = 40
    var tone: AvatarTone = .clay

    enum AvatarTone {
        case clay, sage
        var bg: Color { self == .clay ? .clay200 : .sage300 }
        var fg: Color { self == .clay ? .clay600 : .sage700 }
    }

    var body: some View {
        Text(initial.prefix(1).uppercased())
            .font(.inter(size * 0.42, weight: .semibold))
            .foregroundStyle(tone.fg)
            .frame(width: size, height: size)
            .background(tone.bg)
            .clipShape(Circle())
    }
}
