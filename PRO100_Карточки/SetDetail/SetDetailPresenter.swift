//
//  SetDetailPresenter.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - SetDetailPresenter
final class SetDetailPresenter {
    weak var view: SetDetailViewInput?
    var router: SetDetailRouterProtocol?
    private var set: CardSetModel
    private var cards: [CardModel] = []
    private let mode: SetDetailMode
    private var isFavorite = false
    private var progressText: String?

    init(set: CardSetModel, mode: SetDetailMode) {
        self.set = set
        self.mode = mode
    }
}

// MARK: - SetDetailPresenter Extension
extension SetDetailPresenter: SetDetailViewOutput {
    func viewDidLoad() {
        loadData()
    }

    func viewWillAppear() {
        loadData()
    }

    private func loadData() {
        guard let deckId = Int(set.id) else {
            applyToView()
            return
        }
        switch mode {
        case .myDeck:
            StudyContentService.shared.getMyDeck(id: deckId) { [weak self] result in
                guard let self else { return }
                switch result {
                case .failure(let error):
                    self.view?.showErrorBanner(error.localizedDescription)
                case .success(let dto):
                    self.set = StudyContentMappers.cardSet(from: dto)
                    self.cards = (dto.cards ?? []).map { StudyContentMappers.cardModel($0, deckId: dto.id, setTitle: dto.title) }
                    self.applyToView()
                    self.fetchProgress(deckId: dto.id)
                }
            }
        case .publicCatalog:
            StudyContentService.shared.getPublicDeck(id: deckId) { [weak self] result in
                guard let self else { return }
                switch result {
                case .failure(let error):
                    self.view?.showErrorBanner(error.localizedDescription)
                case .success(let dto):
                    self.set = StudyContentMappers.cardSetFromPublic(detail: dto)
                    self.cards = self.set.cards
                    self.applyToView()
                    self.refreshFavoriteState()
                    self.fetchProgress(deckId: dto.id)
                }
            }
        }
    }

    private func fetchProgress(deckId: Int) {
        StudyContentService.shared.getDeckProgress(deckId: deckId) { [weak self] result in
            guard let self else { return }
            guard case .success(let p) = result else { return }
            self.progressText = "К изучению: \(p.cardsDue) · Новые: \(p.cardsNew) · Освоено: \(p.cardsMastered)"
            self.applyToView()
        }
    }

    private func refreshFavoriteState() {
        guard mode == .publicCatalog, let deckId = Int(set.id) else { return }
        StudyContentService.shared.listFavorites(page: 1, limit: 100) { [weak self] result in
            guard let self else { return }
            guard case .success(let resp) = result else { return }
            let ids = Set(resp.decks.map(\.id))
            self.isFavorite = ids.contains(deckId)
            self.view?.setFavoriteState(self.isFavorite)
        }
    }

    private func applyToView() {
        let tags = set.tags.joined(separator: ", ")
        view?.configureInfo(
            description: set.description,
            category: set.category,
            tags: tags,
            isPrivate: set.isPrivate,
            cardsCount: set.cardCount,
            progressText: progressText
        )
        view?.reloadCards()
        view?.showEmptyState(cards.isEmpty)
    }

    func didTapEdit() {
        router?.openEditSet(set)
    }

    func didTapDelete() {
        view?.showDeleteConfirmAlert { [weak self] in
            guard let self, let id = Int(self.set.id) else { return }
            StudyContentService.shared.deleteDeck(id: id) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    self.router?.closeAfterDelete()
                case .failure(let error):
                    self.view?.showErrorBanner(error.localizedDescription)
                }
            }
        }
    }

    func didTapStartLearning() {
        router?.openLearning(set: set, cards: cards)
    }

    func didTapAddCard() {
        router?.openCreateCard(prefilledSetId: set.id)
    }

    func didTapCopyPublic() {
        guard mode == .publicCatalog, let deckId = Int(set.id) else { return }
        if CopiedPublicDecksStorage.contains(deckId) {
            view?.showErrorBanner("Этот набор уже скопирован в ваши наборы")
            return
        }
        StudyContentService.shared.copyPublicDeck(id: deckId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                CopiedPublicDecksStorage.markCopied(deckId)
                self.view?.showErrorBanner("Набор скопирован в ваши наборы")
            case .failure(let error):
                self.view?.showErrorBanner(error.localizedDescription)
            }
        }
    }

    func didTapToggleFavorite() {
        guard mode == .publicCatalog, let deckId = Int(set.id) else { return }
        if isFavorite {
            StudyContentService.shared.removeFavorite(deckId: deckId) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let resp):
                    self.isFavorite = resp.isFavorite
                    self.view?.setFavoriteState(resp.isFavorite)
                    self.view?.showErrorBanner(resp.message)
                case .failure(let error):
                    self.view?.showErrorBanner(error.localizedDescription)
                }
            }
        } else {
            StudyContentService.shared.addFavorite(deckId: deckId) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let resp):
                    self.isFavorite = resp.isFavorite
                    self.view?.setFavoriteState(resp.isFavorite)
                    self.view?.showErrorBanner(resp.message)
                case .failure(let error):
                    self.view?.showErrorBanner(error.localizedDescription)
                }
            }
        }
    }

    func didTapCard(at index: Int) {
        guard cards.indices.contains(index) else { return }
        router?.openCardDetail(cards, selectedIndex: index, readOnly: mode == .publicCatalog)
    }

    func numberOfCards() -> Int {
        cards.count
    }

    func card(at index: Int) -> CardModel {
        cards[index]
    }

    func getSet() -> CardSetModel {
        set
    }

    func isPublicCatalogMode() -> Bool {
        mode == .publicCatalog
    }
}
