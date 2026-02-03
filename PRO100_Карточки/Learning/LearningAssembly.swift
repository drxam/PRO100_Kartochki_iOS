//
//  LearningAssembly.swift
//  PRO100_Карточки
//

import UIKit

final class LearningAssembly {
    func makeModule(set: CardSetModel) -> UIViewController {
        let vc = LearningViewController()
        let presenter = LearningPresenter(set: set)
        let router = LearningRouter()
        vc.output = presenter
        presenter.view = vc as! any LearningViewInput
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
