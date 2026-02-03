//
//  LoginPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class LoginPresenter {
    weak var view: LoginViewInput?
    var router: LoginRouterProtocol?
}

extension LoginPresenter: LoginViewOutput {
    func viewDidLoad() {}

    func didTapLogin() {
        router?.openMain()
    }

    func didTapForgotPassword() {
        view?.showInDevelopmentAlert()
    }

    func didTapRegister() {
        router?.openRegister()
    }
}
