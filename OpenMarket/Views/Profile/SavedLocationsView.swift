import SwiftUI
import MapKit

struct SavedLocationsView: View {
    @Environment(\.dismiss) private var dismiss
    private let locations = [
        ("Home", "123 Main St, Manama", 26.2235, 50.5876),
        ("Work", "456 Office Blvd, Riffa", 26.1299, 50.5550),
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
                        Text("ACCOUNT").font(.omMicro).foregroundStyle(Color.omTextMuted)
                        Text("Saved locations").font(.serif(28)).foregroundStyle(Color.omText)
                    }
                    .padding(.leading, Spacing.s)
                    Spacer()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.m)

                ScrollView {
                    VStack(spacing: Spacing.m) {
                        ForEach(locations, id: \.0) { loc in
                            HStack(spacing: Spacing.m) {
                                Image(systemName: loc.0 == "Home" ? "house.fill" : "briefcase.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.omAccent)
                                    .frame(width: 40, height: 40)
                                    .background(Color.omAccentSoft)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(loc.0).font(.omBodyMed).foregroundStyle(Color.omText)
                                    Text(loc.1).font(.omCaption).foregroundStyle(Color.omTextMuted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.omTextSubtle)
                            }
                            .padding(Spacing.l)
                            .background(Color.omBgElevated)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                            .overlay(RoundedRectangle(cornerRadius: Radius.md).stroke(Color.omBorder, lineWidth: 1))
                        }

                        Button {
                        } label: {
                            HStack(spacing: Spacing.m) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.omAccent)
                                Text("Add a location")
                                    .font(.inter(15, weight: .semibold))
                                    .foregroundStyle(Color.omAccent)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.l)
                            .background(Color.omAccentSoft)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
