import SwiftUI

struct StarRatingView: View {
    var rating: Double
    var size: CGFloat = 12
    var max: Int = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...max, id: \.self) { i in
                Image(systemName: Double(i) <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(Double(i) <= rating ? Color.omAccent : Color.omBorder)
            }
        }
    }
}

struct StarPickerView: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: Spacing.m) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.system(size: 44))
                    .foregroundStyle(i <= rating ? Color.omAccent : Color.omBorderStrong)
                    .onTapGesture { rating = i }
            }
        }
    }
}
