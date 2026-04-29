//
//  ForgotPasswordRouter.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - ForgotPasswordRouterProtocol
protocol ForgotPasswordRouterProtocol: AnyObject {
    func closeToLogin()
}

// MARK: - ForgotPasswordRouter
final class ForgotPasswordRouter: ForgotPasswordRouterProtocol {
    weak var viewController: UIViewController?

    func closeToLogin() {
        viewController?.dismiss(animated: true)
    }
}
