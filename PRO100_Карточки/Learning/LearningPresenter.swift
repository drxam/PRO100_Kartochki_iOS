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
    private var isCompleted: Bool
    private var useServerSession = false
    private var serverSessionId: Int?
    private var serverCard: StudyCardDTO?
    private var serverTotalCards = 0
    private var serverReviewedCards = 0
    private var isSubmitting = false

    init(set: CardSetModel, cards: [CardModel]) {
        self.set = set
        self.cards = cards
        self.currentIndex = 0
        self.answerShown = false
        self.isCompleted = false
    }
}

extension LearningPresenter: LearningViewOutput {
    func viewDidLoad() {
        startServerSessionIfPossible()
    }

    func didTapClose() {
        router?.close()
    }

    func didTapToggleAnswer() {
        answerShown.toggle()
    }

    func didTapRating(_ rating: LearningRating) {
        if useServerSession {
            submitServerRating(rating)
            return
        }
        answerShown = false
        if currentIndex + 1 < cards.count {
            currentIndex += 1
        } else {
            completeSession()
        }
    }

    func didTapPrevious() {
        if useServerSession { return }
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        answerShown = false
    }

    func didTapNext() {
        if useServerSession { return }
        if currentIndex + 1 < cards.count {
            currentIndex += 1
            answerShown = false
        } else {
            completeSession()
        }
    }

    func didTapRestartLearning() {
        if useServerSession {
            isCompleted = false
            answerShown = false
            serverReviewedCards = 0
            view?.hideCompletion()
            startServerSessionIfPossible()
            return
        }
        isCompleted = false
        currentIndex = 0
        answerShown = false
        view?.hideCompletion()
    }

    func didTapBackToCardsFromCompletion() {
        isCompleted = false
        currentIndex = max(0, cards.count - 1)
        answerShown = false
        view?.hideCompletion()
    }

    func didTapBackToSetsFromCompletion() {
        router?.close()
    }

    private func completeSession() {
        LearningProgressStorage.recordSessionCompleted()
        isCompleted = true
        view?.showCompletion(total: max(cards.count, 1))
    }

    private func startServerSessionIfPossible() {
        guard let deckId = Int(set.id) else { return }
        view?.setInteractionEnabled(false)
        StudyContentService.shared.startStudySession(deckId: deckId) { [weak self] result in
            guard let self else { return }
            self.view?.setInteractionEnabled(true)
            switch result {
            case .failure(let error):
                self.useServerSession = false
                self.view?.showErrorBanner(error.localizedDescription)
                self.view?.refreshContent()
            case .success(let data):
                guard let sid = data.sessionId else {
                    self.useServerSession = false
                    self.view?.refreshContent()
                    return
                }
                self.useServerSession = true
                self.serverSessionId = sid
                self.serverCard = data.card
                self.serverTotalCards = max(data.totalCards ?? 0, 0)
                self.serverReviewedCards = 0
                self.answerShown = false
                if self.serverCard == nil {
                    self.completeSessionServer()
                    return
                }
                self.view?.refreshContent()
            }
        }
    }

    private func submitServerRating(_ rating: LearningRating) {
        guard !isSubmitting, let sid = serverSessionId, let cardId = serverCard?.id else { return }
        isSubmitting = true
        view?.setInteractionEnabled(false)
        StudyContentService.shared.reviewStudyCard(
            sessionId: sid,
            cardId: cardId,
            quality: qualityValue(from: rating)
        ) { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            self.view?.setInteractionEnabled(true)
            switch result {
            case .failure(let error):
                self.view?.showErrorBanner(error.localizedDescription)
            case .success(let data):
                self.answerShown = false
                self.serverReviewedCards += 1
                if let next = data.nextCard {
                    self.serverCard = next
                } else {
                    self.completeSessionServer()
                    return
                }
            }
            self.view?.refreshContent()
        }
    }

    private func qualityValue(from rating: LearningRating) -> Int {
        switch rating {
        case .hard: return 1
        case .medium: return 3
        case .easy: return 5
        }
    }

    private func completeSessionServer() {
        let total = max(serverTotalCards, serverReviewedCards)
        if let sid = serverSessionId {
            StudyContentService.shared.finishStudySession(sessionId: sid) { _ in }
        }
        LearningProgressStorage.recordSessionCompleted()
        isCompleted = true
        view?.showCompletion(total: max(total, 1))
    }

    func currentProgress() -> (current: Int, total: Int) {
        if useServerSession {
            let total = max(serverTotalCards, 1)
            if isCompleted { return (total, total) }
            let current = min(serverReviewedCards + 1, total)
            return (current, total)
        }
        let total = max(cards.count, 1)
        return (min(currentIndex + 1, total), total)
    }

    func currentCardQuestion() -> String {
        if useServerSession {
            return serverCard?.question ?? ""
        }
        guard !cards.isEmpty, currentIndex < cards.count else { return "" }
        return cards[currentIndex].question
    }

    func currentCardAnswer() -> String {
        if useServerSession {
            return serverCard?.answer ?? ""
        }
        guard !cards.isEmpty, currentIndex < cards.count else { return "" }
        return cards[currentIndex].answer
    }

    func isAnswerShown() -> Bool {
        answerShown
    }
}
