//
//  LearningRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol LearningRouterProtocol: AnyObject {
    func close()
}

final class LearningRouter: LearningRouterProtocol {
    weak var viewController: UIViewController?

    func close() {
        viewController?.dismiss(animated: true)
    }
}
