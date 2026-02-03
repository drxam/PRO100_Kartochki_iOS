//
//  LearningPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class LearningPresenter {
    weak var view: LearningViewInput?
    var router: LearningRouterProtocol?
    private let set: CardSetModel
    private var cards: [CardModel]
    private var currentIndex: Int
    private var answerShown: Bool

    init(set: CardSetModel) {
        self.set = set
        self.cards = set.cards.isEmpty ? (MockData.setWithCards(id: set.id)?.cards ?? []) : set.cards
        if self.cards.isEmpty {
            self.cards = (1...5).map { i in
                CardModel(id: "\(set.id)-\(i)", question: "Вопрос карточки \(i)", answer: "Ответ карточки \(i)", setId: set.id, setTitle: set.title, category: set.category, tags: [])
            }
        }
        self.currentIndex = 0
        self.answerShown = false
    }
}

extension LearningPresenter: LearningViewOutput {
    func viewDidLoad() {}

    func didTapClose() {
        router?.close()
    }

    func didTapShowAnswer() {
        answerShown = true
    }

    func didTapRating(_ rating: LearningRating) {
        answerShown = false
        if currentIndex + 1 < cards.count {
            currentIndex += 1
        } else {
            router?.close()
        }
    }

    func currentProgress() -> (current: Int, total: Int) {
        (currentIndex + 1, cards.count)
    }

    func currentCardQuestion() -> String {
        guard currentIndex < cards.count else { return "" }
        return cards[currentIndex].question
    }

    func currentCardAnswer() -> String {
        guard currentIndex < cards.count else { return "" }
        return cards[currentIndex].answer
    }

    func isAnswerShown() -> Bool {
        answerShown
    }
}
