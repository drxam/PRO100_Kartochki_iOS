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
    func viewDidLoad() {
        view?.setPasswordValidation(lengthOK: false, lettersDigitsOK: false)
    }

    func didTapRegister(email: String, password: String, confirmPassword: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard ValidationRules.isValidEmail(trimmedEmail) else {
            view?.showMessage("Некорректный email.")
            return
        }
        let lengthOK = password.count >= ValidationRules.minPasswordLength
        let lettersDigitsOK = ValidationRules.hasLettersAndDigits(password)
        guard lengthOK, lettersDigitsOK else {
            view?.showMessage("Слишком слабый пароль.")
            return
        }
        guard password == confirmPassword else {
            view?.showMessage("Пароли не совпадают.")
            return
        }

        view?.setLoading(true)
        AuthService.shared.register(email: trimmedEmail, password: password) { [weak self] result in
            self?.view?.setLoading(false)
            switch result {
            case .success(let token):
                if token != nil {
                    self?.router?.openMain()
                } else {
                    AuthService.shared.login(email: trimmedEmail, password: password) { loginResult in
                        switch loginResult {
                        case .success:
                            self?.router?.openMain()
                        case .failure(let loginError):
                            self?.view?.showMessage(loginError.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                self?.view?.showMessage(error.localizedDescription)
            }
        }
    }

    func didTapLogin() {
        router?.closeToLogin()
    }

    func didChangePassword(_ password: String) {
        view?.setPasswordValidation(
            lengthOK: password.count >= ValidationRules.minPasswordLength,
            lettersDigitsOK: ValidationRules.hasLettersAndDigits(password)
        )
    }
}
