//
//  PublicListRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol PublicListRouterProtocol: AnyObject {
    func openPublicSetDetail(_ set: PublicSetModel)
}

final class PublicListRouter: PublicListRouterProtocol {
    weak var viewController: UIViewController?

    func openPublicSetDetail(_ set: PublicSetModel) {
        let detailSet = CardSetModel(
            id: set.id,
            title: set.title,
            description: "Публичный набор пользователя \(set.authorName).",
            cardCount: set.cardCount,
            category: set.category,
            tags: [],
            isPrivate: false,
            cards: []
        )
        let vc = SetDetailAssembly().makeModule(set: detailSet, mode: .publicCatalog)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
