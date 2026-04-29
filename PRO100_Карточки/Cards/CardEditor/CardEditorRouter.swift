//
//  CardEditorRouter.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - CardEditorRouterProtocol
protocol CardEditorRouterProtocol: AnyObject {
    func close()
}

// MARK: - CardEditorRouter
final class CardEditorRouter: CardEditorRouterProtocol {
    weak var viewController: UIViewController?

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
