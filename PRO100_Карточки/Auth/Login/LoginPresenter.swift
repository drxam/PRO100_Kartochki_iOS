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

    func didTapLogin(email: String, password: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard ValidationRules.isValidEmail(trimmedEmail) else {
            view?.showMessage("Введите корректный email.")
            return
        }
        guard !password.isEmpty else {
            view?.showMessage("Введите пароль.")
            return
        }

        view?.setLoading(true)
        AuthService.shared.login(email: trimmedEmail, password: password) { [weak self] result in
            self?.view?.setLoading(false)
            switch result {
            case .success:
                self?.router?.openMain()
            case .failure(let error):
                self?.view?.showMessage(error.localizedDescription)
            }
        }
    }

    func didTapForgotPassword() {
        router?.openForgotPassword()
    }

    func didTapRegister() {
        router?.openRegister()
    }
}
