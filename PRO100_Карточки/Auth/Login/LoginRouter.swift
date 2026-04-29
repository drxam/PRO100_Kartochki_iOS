//
//  LoginRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol LoginRouterProtocol: AnyObject {
    func openMain()
    func openRegister()
    func openForgotPassword()
}

final class LoginRouter: LoginRouterProtocol {
    weak var viewController: UIViewController?
    private let assembly: AppAssembly

    init(assembly: AppAssembly) {
        self.assembly = assembly
    }

    func openMain() {
        guard let window = viewController?.view.window else { return }
        let main = assembly.makeMainTabModule()
        window.rootViewController = main
        window.makeKeyAndVisible()
    }

    func openRegister() {
        let assembly = RegisterAssembly()
        let registerVC = assembly.makeModule()
        let nav = UINavigationController(rootViewController: registerVC)
        nav.modalPresentationStyle = .fullScreen
        viewController?.present(nav, animated: true)
    }

    func openForgotPassword() {
        let assembly = ForgotPasswordAssembly()
        let forgotVC = assembly.makeModule()
        let nav = UINavigationController(rootViewController: forgotVC)
        nav.modalPresentationStyle = .fullScreen
        viewController?.present(nav, animated: true)
    }
}
