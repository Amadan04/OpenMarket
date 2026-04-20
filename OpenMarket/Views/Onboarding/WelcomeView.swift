import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.omBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Hero collage
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.clay100)
                            .frame(height: 180)
                            .rotationEffect(.degrees(-4))
                            .offset(x: -16, y: 20)
                            .padding(.trailing, 40)

                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.sage100)
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(6))
                            .offset(x: 60, y: 80)

                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.cream200)
                            .frame(width: 180, height: 200)
                            .rotationEffect(.degrees(-2))
                            .offset(x: -20, y: 140)
                            .overlay(
                                Text("OpenMarket")
                                    .font(.inter(13, weight: .semibold))
                                    .foregroundStyle(Color.omTextMuted)
                                    .offset(x: -20, y: 140)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .clipped()

                    Spacer()

                    // Copy
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Your neighborhood")
                                .font(.serif(48, italic: true))
                                .foregroundStyle(Color.omText)
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            Text("marketplace.")
                                .font(.serif(48))
                                .foregroundStyle(Color.omAccent)
                        }
                        Text("Buy, sell, and find treasures from people just down the street.")
                            .font(.omBody)
                            .foregroundStyle(Color.omTextMuted)
                            .padding(.top, Spacing.s)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.x3)

                    // CTAs
                    VStack(spacing: Spacing.m) {
                        OMButton(label: "Get started", size: .lg, fullWidth: true) {
                            showRegister = true
                        }
                        OMButton(label: "I already have an account", variant: .ghost, size: .md, fullWidth: true) {
                            showLogin = true
                        }
                    }
                    .padding(.horizontal, Spacing.x3)
                    .padding(.top, Spacing.x3)
                    .padding(.bottom, Spacing.x4)
                }
            }
            .navigationDestination(isPresented: $showRegister) { RegisterView() }
            .navigationDestination(isPresented: $showLogin) { LoginView() }
        }
    }
}
