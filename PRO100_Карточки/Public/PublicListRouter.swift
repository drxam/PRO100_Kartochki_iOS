//
//  PublicListRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol PublicListRouterProtocol: AnyObject {}

final class PublicListRouter: PublicListRouterProtocol {
    weak var viewController: UIViewController?
}
