//
//  SetDetailAssembly.swift
//  PRO100_Карточки
//

import UIKit

final class SetDetailAssembly {
    func makeModule(set: CardSetModel) -> UIViewController {
        let vc = SetDetailViewController()
        let presenter = SetDetailPresenter(set: set)
        let router = SetDetailRouter()
        vc.output = presenter
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
