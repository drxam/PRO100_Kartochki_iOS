//
//  SetEditorRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol SetEditorRouterProtocol: AnyObject {
    func close()
}

final class SetEditorRouter: SetEditorRouterProtocol {
    weak var viewController: UIViewController?

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
