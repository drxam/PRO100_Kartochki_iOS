//
//  SetsListPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class SetsListPresenter {
    weak var view: SetsListViewInput?
    var router: SetsListRouterProtocol?
    private var sets: [CardSetModel] = []
    private var selectedCategory = "Все"
}

extension SetsListPresenter: SetsListViewOutput {
    func viewDidLoad() {
        sets = MockData.cardSets
        view?.reloadData()
        view?.showEmptyState(sets.isEmpty)
    }

    func didTapAdd() {
        view?.showInDevelopmentAlert()
    }

    func didSelectSet(_ set: CardSetModel) {
        router?.openSetDetail(set)
    }

    func didSelectCategory(_ category: String) {
        selectedCategory = category
        if category == "Все" {
            sets = MockData.cardSets
        } else {
            sets = MockData.cardSets.filter { $0.category == category }
        }
        view?.reloadData()
        view?.showEmptyState(sets.isEmpty)
    }

    func numberOfSets() -> Int {
        sets.count
    }

    func set(at index: Int) -> CardSetModel {
        sets[index]
    }
}
