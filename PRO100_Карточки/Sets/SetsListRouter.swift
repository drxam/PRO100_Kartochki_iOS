//
//  SetsListRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol SetsListRouterProtocol: AnyObject {
    func openSetDetail(_ set: CardSetModel)
}

final class SetsListRouter: SetsListRouterProtocol {
    weak var viewController: UIViewController?

    func openSetDetail(_ set: CardSetModel) {
        let assembly = SetDetailAssembly()
        let vc = assembly.makeModule(set: set)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
