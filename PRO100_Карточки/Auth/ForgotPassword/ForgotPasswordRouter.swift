//
//  ForgotPasswordRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol ForgotPasswordRouterProtocol: AnyObject {
    func closeToLogin()
}

final class ForgotPasswordRouter: ForgotPasswordRouterProtocol {
    weak var viewController: UIViewController?

    func closeToLogin() {
        viewController?.dismiss(animated: true)
    }
}
