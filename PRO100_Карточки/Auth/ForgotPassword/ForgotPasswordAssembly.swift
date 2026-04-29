//
//  ForgotPasswordAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - ForgotPasswordAssembly
final class ForgotPasswordAssembly {
    func makeModule() -> UIViewController {
        let viewController = ForgotPasswordViewController()
        let presenter = ForgotPasswordPresenter()
        let router = ForgotPasswordRouter()
        viewController.output = presenter
        presenter.view = viewController
        presenter.router = router
        router.viewController = viewController
        return viewController
    }
}
