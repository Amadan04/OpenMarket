import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var showTabBar = true
    @Published var sessionExpired = false
    static let shared = AppState()
}
