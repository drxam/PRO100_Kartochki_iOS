//
//  SetEditorRouter.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - SetEditorRouterProtocol
protocol SetEditorRouterProtocol: AnyObject {
    func close()
}

// MARK: - SetEditorRouter
final class SetEditorRouter: SetEditorRouterProtocol {
    weak var viewController: UIViewController?

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
