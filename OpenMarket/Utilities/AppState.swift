import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var showTabBar = true
    @Published var sessionExpired = false
    @Published var selectedTab: OMTab = .home
    static let shared = AppState()
}
