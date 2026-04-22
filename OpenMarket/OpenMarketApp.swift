import SwiftUI

@main
struct OpenMarketApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(appState)
        }
    }
}
