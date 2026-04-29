//
//  SetEditorAssembly.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - SetEditorMode
enum SetEditorMode {
    case create
    case edit(CardSetModel)
}

// MARK: - SetEditorAssembly
final class SetEditorAssembly {
    func makeModule(mode: SetEditorMode) -> UIViewController {
        let vc = SetEditorViewController()
        let presenter = SetEditorPresenter(mode: mode)
        let router = SetEditorRouter()
        vc.output = presenter
        presenter.view = vc
        presenter.router = router
        router.viewController = vc
        return vc
    }
}
