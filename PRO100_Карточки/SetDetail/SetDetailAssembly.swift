//
//  SetDetailAssembly.swift
//  PRO100_Карточки
//

import UIKit

enum SetDetailMode {
    /// Мой набор: CRUD, обучение.
    case myDeck
    /// Каталог: только просмотр и обучение.
    case publicCatalog
}

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
