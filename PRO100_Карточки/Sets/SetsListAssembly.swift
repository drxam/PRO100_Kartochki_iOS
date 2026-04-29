//
//  SetsListAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - SetsListAssembly
final class SetsListAssembly {
    func makeModule() -> UIViewController {
        let vc = SetsListViewController()
        let presenter = SetsListPresenter()
        let router = SetsListRouter()
        vc.output = presenter
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
