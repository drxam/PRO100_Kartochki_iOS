//
//  RegisterAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - RegisterAssembly
final class RegisterAssembly {
    func makeModule() -> UIViewController {
        let viewController = RegisterViewController()
        let presenter = RegisterPresenter()
        let router = RegisterRouter()
        viewController.output = presenter
        presenter.view = viewController
        presenter.router = router
        router.viewController = viewController
        return viewController
    }
}
