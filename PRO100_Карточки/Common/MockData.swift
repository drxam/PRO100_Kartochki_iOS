//
//  MockData.swift
//  PRO100_Карточки
//

import Foundation

enum MockData {
    static let categories = ["Все", "Языки", "Наука", "История"]

    static let userProfile = UserProfileModel(
        name: "Иван Иванов",
        email: "user@example.com",
        setsCount: 5,
        cardsCount: 42,
        learningProgress: 68
    )

    static let cardSets: [CardSetModel] = [
        CardSetModel(
            id: "1",
            title: "Английские неправильные глаголы",
            description: "Топ-50 неправильных глаголов с переводом и примерами использования в предложениях.",
            cardCount: 12,
            category: "Языки",
            isPrivate: false,
            cards: []
        ),
        CardSetModel(
            id: "2",
            title: "Формулы по физике",
            description: "Основные формулы механики, термодинамики и электричества для подготовки к экзамену.",
            cardCount: 25,
            category: "Наука",
            isPrivate: true,
            cards: []
        ),
        CardSetModel(
            id: "3",
            title: "Даты Второй мировой",
            description: "Ключевые даты и события Второй мировой войны для быстрого повторения.",
            cardCount: 18,
            category: "История",
            isPrivate: false,
            cards: []
        ),
        CardSetModel(
            id: "4",
            title: "Немецкие артикли",
            description: "Определённый и неопределённый артикли в немецком языке с примерами.",
            cardCount: 8,
            category: "Языки",
            isPrivate: true,
            cards: []
        ),
        CardSetModel(
            id: "5",
            title: "Химические элементы",
            description: "Символы и названия элементов периодической таблицы.",
            cardCount: 30,
            category: "Наука",
            isPrivate: false,
            cards: []
        )
    ]

    static let cards: [CardModel] = [
        CardModel(id: "c1", question: "Как переводится 'to run'?", answer: "Бежать", setId: "1", setTitle: "Английские неправильные глаголы", category: "Языки", tags: ["глагол"]),
        CardModel(id: "c2", question: "Past Simple от 'to go'?", answer: "Went", setId: "1", setTitle: "Английские неправильные глаголы", category: "Языки", tags: ["глагол"]),
        CardModel(id: "c3", question: "Формула кинетической энергии?", answer: "E = mv²/2", setId: "2", setTitle: "Формулы по физике", category: "Наука", tags: ["механика"]),
        CardModel(id: "c4", question: "Закон Ома?", answer: "I = U/R", setId: "2", setTitle: "Формулы по физике", category: "Наука", tags: ["электричество"]),
        CardModel(id: "c5", question: "Когда началась Вторая мировая?", answer: "1 сентября 1939 года", setId: "3", setTitle: "Даты Второй мировой", category: "История", tags: ["даты"]),
        CardModel(id: "c6", question: "Артикль der для какого рода?", answer: "Мужской род", setId: "4", setTitle: "Немецкие артикли", category: "Языки", tags: ["артикли"]),
        CardModel(id: "c7", question: "Символ золота?", answer: "Au", setId: "5", setTitle: "Химические элементы", category: "Наука", tags: ["химия"])
    ]

    static let publicSets: [PublicSetModel] = [
        PublicSetModel(id: "p1", title: "Испанский для начинающих", cardCount: 50, category: "Языки", authorName: "Мария Петрова", authorAvatarPlaceholder: true),
        PublicSetModel(id: "p2", title: "Астрономия: планеты", cardCount: 15, category: "Наука", authorName: "Алексей Козлов", authorAvatarPlaceholder: true),
        PublicSetModel(id: "p3", title: "Древний Рим", cardCount: 22, category: "История", authorName: "Елена Смирнова", authorAvatarPlaceholder: true),
        PublicSetModel(id: "p4", title: "Французские глаголы", cardCount: 40, category: "Языки", authorName: "Дмитрий Волков", authorAvatarPlaceholder: true)
    ]

    static func setWithCards(id: String) -> CardSetModel? {
        guard let set = cardSets.first(where: { $0.id == id }) else { return nil }
        let setCards = cards.filter { $0.setId == id }
        if setCards.isEmpty {
            return CardSetModel(id: set.id, title: set.title, description: set.description, cardCount: set.cardCount, category: set.category, isPrivate: set.isPrivate, cards: (1...5).map { i in
                CardModel(id: "\(set.id)-\(i)", question: "Вопрос карточки \(i)", answer: "Ответ карточки \(i)", setId: set.id, setTitle: set.title, category: set.category, tags: [])
            })
        }
        return CardSetModel(id: set.id, title: set.title, description: set.description, cardCount: set.cardCount, category: set.category, isPrivate: set.isPrivate, cards: setCards)
    }
}
