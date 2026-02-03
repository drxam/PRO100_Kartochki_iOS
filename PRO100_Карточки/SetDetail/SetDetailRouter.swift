//
//  SetDetailRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol SetDetailRouterProtocol: AnyObject {
    func closeAfterDelete()
    func openLearning(set: CardSetModel)
}

final class SetDetailRouter: SetDetailRouterProtocol {
    weak var viewController: UIViewController?

    func closeAfterDelete() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func openLearning(set: CardSetModel) {
        let assembly = LearningAssembly()
        let vc = assembly.makeModule(set: set)
        vc.modalPresentationStyle = .fullScreen
        viewController?.present(vc, animated: true)
    }
}
