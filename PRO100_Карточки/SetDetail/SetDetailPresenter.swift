//
//  SetDetailPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class SetDetailPresenter {
    weak var view: SetDetailViewInput?
    var router: SetDetailRouterProtocol?
    private var set: CardSetModel
    private var cards: [CardModel] = []

    init(set: CardSetModel) {
        self.set = set
    }
}

extension SetDetailPresenter: SetDetailViewOutput {
    func viewDidLoad() {
        if let fullSet = MockData.setWithCards(id: set.id) {
            set = fullSet
            cards = fullSet.cards
        }
        let tags = Array(Set(cards.flatMap { $0.tags })).joined(separator: ", ")
        view?.configureInfo(description: set.description, category: set.category, tags: tags, isPrivate: set.isPrivate)
        view?.reloadCards()
        view?.showEmptyState(cards.isEmpty)
    }

    func didTapEdit() {
        view?.showInDevelopmentAlert()
    }

    func didTapDelete() {
        view?.showDeleteConfirmAlert { [weak self] in
            self?.router?.closeAfterDelete()
        }
    }

    func didTapStartLearning() {
        router?.openLearning(set: set)
    }

    func didTapAddCard() {
        view?.showInDevelopmentAlert()
    }

    func didTapCard(at index: Int) {
        view?.showInDevelopmentAlert()
    }

    func numberOfCards() -> Int {
        cards.count
    }

    func card(at index: Int) -> CardModel {
        cards[index]
    }

    func getSet() -> CardSetModel {
        set
    }
}
