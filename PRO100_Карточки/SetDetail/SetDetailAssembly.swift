//
//  SetDetailAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - SetDetailMode
enum SetDetailMode {
    case myDeck
    case publicCatalog
}

// MARK: - SetDetailAssembly
final class SetDetailAssembly {
    func makeModule(set: CardSetModel, mode: SetDetailMode = .myDeck) -> UIViewController {
        let vc = SetDetailViewController()
        let presenter = SetDetailPresenter(set: set, mode: mode)
        let router = SetDetailRouter()
        vc.output = presenter
        vc.isEditable = (mode == .myDeck)
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
