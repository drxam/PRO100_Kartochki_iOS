//
//  ProfileAssembly.swift
//  PRO100_Карточки
//

import UIKit

final class ProfileAssembly {
    func makeModule() -> UIViewController {
        let vc = ProfileViewController()
        let presenter = ProfilePresenter()
        let router = ProfileRouter()
        vc.output = presenter
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
