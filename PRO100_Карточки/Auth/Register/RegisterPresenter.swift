//
//  RegisterPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class RegisterPresenter {
    weak var view: RegisterViewInput?
    var router: RegisterRouterProtocol?
}

extension RegisterPresenter: RegisterViewOutput {
    func viewDidLoad() {}

    func didTapRegister() {
        router?.openMain()
    }

    func didTapLogin() {
        router?.closeToLogin()
    }
}
