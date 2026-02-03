//
//  LoginRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol LoginRouterProtocol: AnyObject {
    func openMain()
    func openRegister()
}

final class LoginRouter: LoginRouterProtocol {
    weak var viewController: UIViewController?
    private let assembly: AppAssembly

    init(assembly: AppAssembly) {
        self.assembly = assembly
    }

    func openMain() {
        let main = assembly.makeMainTabModule()
        main.modalPresentationStyle = .fullScreen
        viewController?.present(main, animated: true)
    }

    func openRegister() {
        let assembly = RegisterAssembly()
        let registerVC = assembly.makeModule()
        registerVC.modalPresentationStyle = .fullScreen
        viewController?.present(registerVC, animated: true)
    }
}
