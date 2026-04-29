import Foundation

enum CopiedPublicDecksStorage {
    private static let key = "copied_public_deck_ids"

    static func contains(_ deckId: Int) -> Bool {
        ids().contains(deckId)
    }

    static func markCopied(_ deckId: Int) {
        var set = ids()
        set.insert(deckId)
        save(set)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    private static func ids() -> Set<Int> {
        let arr = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
        return Set(arr)
    }

    private static func save(_ set: Set<Int>) {
        UserDefaults.standard.set(Array(set), forKey: key)
    }
}

