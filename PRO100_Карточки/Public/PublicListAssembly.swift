//
//  PublicListAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - PublicListAssembly
final class PublicListAssembly {
    func makeModule() -> UIViewController {
        let vc = PublicListViewController()
        let presenter = PublicListPresenter()
        let router = PublicListRouter()
        vc.output = presenter
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
