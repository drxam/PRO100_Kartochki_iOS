//
//  LearningRouter.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - LearningRouterProtocol
protocol LearningRouterProtocol: AnyObject {
    func close()
}

// MARK: - LearningRouter
final class LearningRouter: LearningRouterProtocol {
    weak var viewController: UIViewController?

    func close() {
        viewController?.dismiss(animated: true)
    }
}
