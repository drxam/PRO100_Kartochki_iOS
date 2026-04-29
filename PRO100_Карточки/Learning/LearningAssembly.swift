//
//  LearningAssembly.swift
//  PRO100_Карточки
//

import UIKit

final class LearningAssembly {
    func makeModule(set: CardSetModel, cards: [CardModel]) -> UIViewController {
        let vc = LearningViewController()
        let presenter = LearningPresenter(set: set, cards: cards)
        let router = LearningRouter()
        vc.output = presenter
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
