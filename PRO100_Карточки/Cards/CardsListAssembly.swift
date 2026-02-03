//
//  CardsListAssembly.swift
//  PRO100_Карточки
//

import UIKit

final class CardsListAssembly {
    func makeModule() -> UIViewController {
        let vc = CardsListViewController()
        let presenter = CardsListPresenter()
        let router = CardsListRouter()
        vc.output = presenter
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
