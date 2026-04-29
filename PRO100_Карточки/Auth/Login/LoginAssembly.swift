//
//  LoginAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - LoginAssembly
final class LoginAssembly {
    func makeModule() -> UIViewController {
        let viewController = LoginViewController()
        let presenter = LoginPresenter()
        let router = LoginRouter(assembly: AppAssembly())
        viewController.output = presenter
        presenter.view = viewController
        presenter.router = router
        router.viewController = viewController
        return viewController
    }
}
