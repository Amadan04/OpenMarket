import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
    }
}

struct MainTabView: View {
    @State private var selectedTab: OMTab = .home
    @State private var showSell = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:     HomeView()
                case .map:      MapView()
                case .sell:     HomeView() // placeholder, handled by sheet
                case .messages: ConversationsView()
                case .profile:  ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 84) }

            OMTabBar(selected: $selectedTab, onSell: { showSell = true })
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showSell) {
            AddProductView()
        }
    }
}
