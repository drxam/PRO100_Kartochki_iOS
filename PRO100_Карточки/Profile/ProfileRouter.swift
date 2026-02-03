//
//  ProfileRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol ProfileRouterProtocol: AnyObject {
    func logout()
}

final class ProfileRouter: ProfileRouterProtocol {
    weak var viewController: UIViewController?

    func logout() {
        guard let tabBar = viewController?.navigationController?.tabBarController else { return }
        tabBar.presentingViewController?.dismiss(animated: true)
    }
}
