import SwiftUI

// MARK: - Colors
extension Color {
    // Raw palette — neutrals
    static let cream50  = Color(hex: "#FBF7F1")
    static let cream100 = Color(hex: "#F4ECE0")
    static let cream200 = Color(hex: "#E8DDC9")
    static let stone300 = Color(hex: "#C9BCA3")
    static let stone400 = Color(hex: "#9B8F78")
    static let stone500 = Color(hex: "#6B6253")
    static let stone600 = Color(hex: "#4A4338")
    static let stone700 = Color(hex: "#2F2A22")
    static let stone800 = Color(hex: "#1C1914")

    // Raw palette — clay (accent)
    static let clay50  = Color(hex: "#FBEEE6")
    static let clay100 = Color(hex: "#F7D9C6")
    static let clay200 = Color(hex: "#EDB093")
    static let clay300 = Color(hex: "#E08865")
    static let clay400 = Color(hex: "#D26B47")
    static let clay500 = Color(hex: "#B8532F")
    static let clay600 = Color(hex: "#8F3E22")

    // Raw palette — sage
    static let sage100 = Color(hex: "#E5ECD9")
    static let sage300 = Color(hex: "#A8B785")
    static let sage500 = Color(hex: "#6F8349")
    static let sage700 = Color(hex: "#46552A")

    // Semantic
    static let omBg          = Color(hex: "#FBF7F1")
    static let omBgElevated  = Color(hex: "#FFFFFF")
    static let omBgSunken    = Color(hex: "#F4ECE0")
    static let omBorder      = Color(hex: "#E8DDC9")
    static let omBorderStrong = Color(hex: "#C9BCA3")

    static let omText        = Color(hex: "#1C1914")
    static let omTextMuted   = Color(hex: "#6B6253")
    static let omTextSubtle  = Color(hex: "#9B8F78")

    static let omAccent      = Color(hex: "#D26B47")
    static let omAccentSoft  = Color(hex: "#FBEEE6")

    static let omDanger      = Color(hex: "#B8413A")
    static let omWarn        = Color(hex: "#C98B2B")
    static let omOk          = Color(hex: "#6F8349")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Typography
extension Font {
    // Instrument Serif — add InstrumentSerif-Regular.ttf + InstrumentSerif-Italic.ttf
    // to Xcode project and register in Info.plist under "Fonts provided by application"
    static func serif(_ size: CGFloat, italic: Bool = false) -> Font {
        let name = italic ? "InstrumentSerif-Italic" : "InstrumentSerif-Regular"
        return .custom(name, size: size)
    }

    // Inter — add Inter-Regular/Medium/SemiBold/Bold.ttf or use system SF Pro
    static func inter(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // Scale
    static let omDisplay  = serif(44)
    static let omTitle1   = serif(34)
    static let omTitle2   = inter(22, weight: .semibold)
    static let omTitle3   = inter(18, weight: .semibold)
    static let omBody     = inter(16)
    static let omBodyMed  = inter(16, weight: .medium)
    static let omCallout  = inter(15, weight: .medium)
    static let omCaption  = inter(13, weight: .medium)
    static let omMicro    = inter(11, weight: .semibold)
    static let omPrice    = inter(20, weight: .bold)
}

// MARK: - Spacing
enum Spacing {
    static let xs:  CGFloat = 4
    static let s:   CGFloat = 8
    static let m:   CGFloat = 12
    static let l:   CGFloat = 16
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 24
    static let x3:  CGFloat = 32
    static let x4:  CGFloat = 40
    static let x5:  CGFloat = 56
}

// MARK: - Radius
enum Radius {
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 20
    static let xxl: CGFloat = 28
    static let pill: CGFloat = 999
}
