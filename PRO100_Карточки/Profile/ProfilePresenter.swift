//
//  ProfilePresenter.swift
//  PRO100_Карточки
//

import Foundation

final class ProfilePresenter {
    weak var view: ProfileViewInput?
    var router: ProfileRouterProtocol?
}

extension ProfilePresenter: ProfileViewOutput {
    func viewDidLoad() {
        view?.configure(profile: MockData.userProfile)
    }

    func didTapEditProfile() {
        view?.showInDevelopmentAlert()
    }

    func didTapLogout() {
        view?.showLogoutConfirm { [weak self] in
            self?.router?.logout()
        }
    }
}
