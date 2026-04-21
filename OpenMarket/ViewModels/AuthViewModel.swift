import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        if KeychainHelper.getToken() != nil {
            Task { await fetchMe() }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await AuthService.login(email: email, password: password)
            KeychainHelper.saveToken(response.token)
            KeychainHelper.saveUserID(response.user.id)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func register(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await AuthService.register(name: name, email: email, password: password)
            KeychainHelper.saveToken(response.token)
            KeychainHelper.saveUserID(response.user.id)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        KeychainHelper.clear()
        currentUser = nil
        isAuthenticated = false
    }

    private func fetchMe() async {
        do {
            currentUser = try await AuthService.me()
            isAuthenticated = true
        } catch {
            KeychainHelper.clear()
        }
    }
}
