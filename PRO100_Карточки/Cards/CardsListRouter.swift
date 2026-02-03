//
//  CardsListRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol CardsListRouterProtocol: AnyObject {}

final class CardsListRouter: CardsListRouterProtocol {
    weak var viewController: UIViewController?
}
