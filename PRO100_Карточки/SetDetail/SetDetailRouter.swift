//
//  SetDetailRouter.swift
//  PRO100_Карточки
//

import UIKit

protocol SetDetailRouterProtocol: AnyObject {
    func closeAfterDelete()
    func openLearning(set: CardSetModel, cards: [CardModel])
    func openCardDetail(_ cards: [CardModel], selectedIndex: Int, readOnly: Bool)
    func openEditSet(_ set: CardSetModel)
    func openCreateCard(prefilledSetId: String)
}

final class SetDetailRouter: SetDetailRouterProtocol {
    weak var viewController: UIViewController?

    func closeAfterDelete() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func openLearning(set: CardSetModel, cards: [CardModel]) {
        let assembly = LearningAssembly()
        let vc = assembly.makeModule(set: set, cards: cards)
        vc.modalPresentationStyle = .fullScreen
        viewController?.present(vc, animated: true)
    }

    func openCardDetail(_ cards: [CardModel], selectedIndex: Int, readOnly: Bool) {
        let vc = CardDetailViewController(cards: cards, selectedIndex: selectedIndex, readOnly: readOnly)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func openEditSet(_ set: CardSetModel) {
        let vc = SetEditorAssembly().makeModule(mode: .edit(set))
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func openCreateCard(prefilledSetId: String) {
        let vc = CardEditorAssembly().makeModule(mode: .create(prefilledSetId: prefilledSetId))
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
