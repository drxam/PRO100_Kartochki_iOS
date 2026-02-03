//
//  RegisterRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol RegisterRouterProtocol: AnyObject {
    func openMain()
    func closeToLogin()
}

final class RegisterRouter: RegisterRouterProtocol {
    weak var viewController: UIViewController?
    private let assembly = AppAssembly()

    func openMain() {
        guard let vc = viewController, let window = vc.view.window else { return }
        let root = window.rootViewController
        let main = assembly.makeMainTabModule()
        main.modalPresentationStyle = .fullScreen
        vc.dismiss(animated: true) {
            root?.present(main, animated: true)
        }
    }

    func closeToLogin() {
        viewController?.dismiss(animated: true)
    }
}
