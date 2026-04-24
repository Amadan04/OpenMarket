import Foundation
import Combine

final class SearchHistoryStore: ObservableObject {
    static let shared = SearchHistoryStore()

    @Published private(set) var terms: [String] = []

    private let key = "search_history_v1"
    private let limit = 10

    private init() { load() }

    func record(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var updated = terms.filter { $0.lowercased() != trimmed.lowercased() }
        updated.insert(trimmed, at: 0)
        terms = Array(updated.prefix(limit))
        save()
    }

    func remove(_ term: String) {
        terms.removeAll { $0 == term }
        save()
    }

    func clear() {
        terms = []
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func save() {
        UserDefaults.standard.set(terms, forKey: key)
    }

    private func load() {
        terms = UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}
