//
//  ProfileRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol ProfileRouterProtocol: AnyObject {
    func logout()
    func openEditProfile(_ profile: UserProfileModel)
}

final class ProfileRouter: ProfileRouterProtocol {
    weak var viewController: UIViewController?
    private let appAssembly = AppAssembly()

    func logout() {
        AuthService.shared.logout { [weak self] _ in
            AuthStorage.shared.clearToken()
            LearningProgressStorage.clear()
            CopiedPublicDecksStorage.clear()
            guard let window = self?.viewController?.view.window else { return }
            window.rootViewController = self?.appAssembly.makeAuthModule()
            window.makeKeyAndVisible()
        }
    }

    func openEditProfile(_ profile: UserProfileModel) {
        let vc = ProfileEditAssembly().makeModule(profile: profile)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
