//
//  CardEditorAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - CardEditorMode
enum CardEditorMode {
    case create(prefilledSetId: String?)
    case edit(CardModel)
}

// MARK: - CardEditorAssembly
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
