//
//  SetsListRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol SetsListRouterProtocol: AnyObject {
    func openSetDetail(_ set: CardSetModel)
    func openCreateSet()
}

final class SetsListRouter: SetsListRouterProtocol {
    weak var viewController: UIViewController?

    func openSetDetail(_ set: CardSetModel) {
        let assembly = SetDetailAssembly()
        let vc = assembly.makeModule(set: set)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func openCreateSet() {
        let vc = SetEditorAssembly().makeModule(mode: .create)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
