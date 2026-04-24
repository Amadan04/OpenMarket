import SwiftUI

@main
struct OpenMarketApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(appState)
                .onAppear {
                    NotificationService.shared.registerIfAuthorized()
                }
        }
    }
}
