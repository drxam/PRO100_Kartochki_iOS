//
//  PublicListPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class PublicListPresenter {
    weak var view: PublicListViewInput?
    var router: PublicListRouterProtocol?
    private var sets: [PublicSetModel] = []
    private var selectedCategory = "Все"
}

extension PublicListPresenter: PublicListViewOutput {
    func viewDidLoad() {
        sets = MockData.publicSets
        view?.reloadData()
        view?.showEmptyState(sets.isEmpty)
    }

    func didSelectCategory(_ category: String) {
        selectedCategory = category
        if category == "Все" {
            sets = MockData.publicSets
        } else {
            sets = MockData.publicSets.filter { $0.category == category }
        }
        view?.reloadData()
        view?.showEmptyState(sets.isEmpty)
    }

    func didSelectSort() {
        view?.showInDevelopmentAlert()
    }

    func didSelectSet() {
        view?.showInDevelopmentAlert()
    }

    func numberOfSets() -> Int { sets.count }
    func publicSet(at index: Int) -> PublicSetModel { sets[index] }
}
