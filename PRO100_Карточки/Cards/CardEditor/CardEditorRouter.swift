//
//  CardEditorRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol CardEditorRouterProtocol: AnyObject {
    func close()
}

final class CardEditorRouter: CardEditorRouterProtocol {
    weak var viewController: UIViewController?

    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
