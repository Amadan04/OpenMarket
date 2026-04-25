import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject private var appState = AppState.shared

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
        .onChange(of: appState.sessionExpired) { _, expired in
            if expired {
                authViewModel.logout()
                AppState.shared.sessionExpired = false
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: OMTab = .home
    @State private var showSell = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:     HomeView()
                case .map:      MapView()
                case .sell:     HomeView()
                case .messages: ConversationsView()
                case .profile:  ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
            .animation(.easeInOut(duration: 0.2), value: selectedTab)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: appState.showTabBar ? 84 : 0) }

            if appState.showTabBar {
                OMTabBar(selected: $selectedTab, onSell: { showSell = true })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: appState.showTabBar)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showSell) {
            AddProductView()
        }
    }
}
