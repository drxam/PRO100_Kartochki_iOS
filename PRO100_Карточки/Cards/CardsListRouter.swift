//
//  CardsListRouter.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - CardsListRouterProtocol
protocol CardsListRouterProtocol: AnyObject {
    func openCardDetail(cards: [CardModel], selectedIndex: Int)
    func openCreateCard()
}

// MARK: - CardsListRouter
final class CardsListRouter: CardsListRouterProtocol {
    weak var viewController: UIViewController?

    func openCardDetail(cards: [CardModel], selectedIndex: Int) {
        let vc = CardDetailViewController(cards: cards, selectedIndex: selectedIndex)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func openCreateCard() {
        let vc = CardEditorAssembly().makeModule(mode: .create(prefilledSetId: nil))
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
