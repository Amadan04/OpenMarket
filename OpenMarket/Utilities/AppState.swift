import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var showTabBar = true
    static let shared = AppState()
}
