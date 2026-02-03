//
//  CardsListPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class CardsListPresenter {
    weak var view: CardsListViewInput?
    var router: CardsListRouterProtocol?
    private var cards: [CardModel] = []
    private var selectedCategory = "Все"
}

extension CardsListPresenter: CardsListViewOutput {
    func viewDidLoad() {
        cards = MockData.cards
        view?.reloadData()
        view?.showEmptyState(cards.isEmpty)
    }

    func didTapAdd() {
        view?.showInDevelopmentAlert()
    }

    func didSelectCard(_ card: CardModel) {
        view?.showInDevelopmentAlert()
    }

    func didSelectCategory(_ category: String) {
        selectedCategory = category
        if category == "Все" {
            cards = MockData.cards
        } else {
            cards = MockData.cards.filter { $0.category == category }
        }
        view?.reloadData()
        view?.showEmptyState(cards.isEmpty)
    }

    func numberOfCards() -> Int { cards.count }
    func card(at index: Int) -> CardModel { cards[index] }
}
