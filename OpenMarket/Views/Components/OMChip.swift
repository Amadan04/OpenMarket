import SwiftUI

struct OMChip: View {
    let label: String
    var active: Bool = false
    var emoji: String? = nil
    var large: Bool = false

    var body: some View {
        HStack(spacing: Spacing.s) {
            if let e = emoji { Text(e).font(.system(size: large ? 16 : 14)) }
            Text(label)
                .font(.inter(large ? 14 : 13, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(active ? Color.white : Color.omText)
        .padding(.horizontal, large ? Spacing.l : Spacing.m)
        .frame(height: large ? 40 : 32)
        .background(active ? (large ? Color.stone700 : Color.omAccent) : Color.omBgElevated)
        .clipShape(Capsule())
        .overlay(active ? nil : Capsule().stroke(Color.omBorder, lineWidth: 1))
    }
}
