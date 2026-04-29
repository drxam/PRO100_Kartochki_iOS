//
//  CardEditorAssembly.swift
//  PRO100_Карточки
//

import UIKit

enum CardEditorMode {
    case create(prefilledSetId: String?)
    case edit(CardModel)
}

final class CardEditorAssembly {
    func makeModule(mode: CardEditorMode) -> UIViewController {
        let vc = CardEditorViewController()
        let presenter = CardEditorPresenter(mode: mode)
        let router = CardEditorRouter()
        vc.output = presenter
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
