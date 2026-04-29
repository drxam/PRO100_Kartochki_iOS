//
//  ForgotPasswordPresenter.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - ForgotPasswordPresenter
final class ForgotPasswordPresenter {
    weak var view: ForgotPasswordViewInput?
    var router: ForgotPasswordRouterProtocol?
}

// MARK: - ForgotPasswordPresenter Extension
extension ForgotPasswordPresenter: ForgotPasswordViewOutput {
    func viewDidLoad() {}

    func didTapSend(email: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard ValidationRules.isValidEmail(trimmedEmail) else {
            view?.showStatusMessage("Введите корректный email.", isError: true)
            return
        }

        view?.setLoading(true)
        AuthService.shared.requestPasswordReset(email: trimmedEmail) { [weak self] result in
            self?.view?.setLoading(false)
            switch result {
            case .success:
                self?.view?.showStatusMessage("Письмо отправлено. Проверьте почтовый ящик.", isError: false)
            case .failure(let error):
                self?.view?.showStatusMessage(error.localizedDescription, isError: true)
            }
        }
    }

    func didTapBackToLogin() {
        router?.closeToLogin()
    }
}
