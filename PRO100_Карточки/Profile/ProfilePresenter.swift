//
//  ProfilePresenter.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - ProfilePresenter
final class ProfilePresenter {
    weak var view: ProfileViewInput?
    var router: ProfileRouterProtocol?
    private var profile = UserProfileModel(
        name: "Загрузка…",
        email: "",
        role: "Пользователь",
        registeredAt: "-",
        setsCount: 0,
        cardsCount: 0,
        learningProgress: LearningProgressStorage.displayPercent()
    )
}

// MARK: - ProfilePresenter Extension
extension ProfilePresenter: ProfileViewOutput {
    func viewDidLoad() {
        view?.configure(profile: profile)
        UserService.shared.fetchMe { [weak self] result in
            switch result {
            case .success(let serverProfile):
                self?.profile = serverProfile
                self?.view?.configure(profile: serverProfile)
            case .failure(let error):
                self?.view?.showError(error.localizedDescription)
            }
        }
    }

    func didTapEditProfile() {
        router?.openEditProfile(profile)
    }

    func didTapLogout() {
        view?.showLogoutConfirm { [weak self] in
            self?.router?.logout()
        }
    }
}
