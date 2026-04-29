//
//  PublicListPresenter.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - PublicListPresenter
final class PublicListPresenter {
    weak var view: PublicListViewInput?
    var router: PublicListRouterProtocol?
    private var sets: [PublicSetModel] = []
    private var allCategories: [APICategory] = []
    private var categoryNameToId: [String: Int] = [:]
    private var selectedCategory = "Все"
    private var searchText = ""
    private var selectedSort = "Популярность"
    private var favoritesOnly = false
    private var lastPagination: PaginationDTO?
    private var isLoading = false
    private var publicDecksLoadGeneration = 0
}

// MARK: - PublicListPresenter Extension
extension PublicListPresenter: PublicListViewOutput {
    func viewDidLoad() {
        StudyContentService.shared.fetchCategories { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let list):
                self.allCategories = list
                for c in list {
                    self.categoryNameToId[c.name] = c.id
                }
                self.refreshCategoryChips()
            case .failure:
                self.allCategories = []
                self.refreshCategoryChips()
            }
        }
        view?.setSortTitle(selectedSort)
        view?.setFavoritesTitle("Избранные: выкл")
        loadPage(reset: true)
    }

    func viewWillAppear() {
        view?.setSortTitle(selectedSort)
    }

    func didSelectCategory(_ category: String) {
        selectedCategory = category
        loadPage(reset: true)
    }

    func didSelectSort() {
        view?.showSortOptions(selected: selectedSort)
    }

    func didSelectSortOption(_ option: String) {
        selectedSort = option
        view?.setSortTitle(option)
        loadPage(reset: true)
    }

    func didTapFavoritesToggle() {
        favoritesOnly.toggle()
        view?.setFavoritesTitle(favoritesOnly ? "Избранные: вкл" : "Избранные: выкл")
        loadPage(reset: true)
    }

    func didSearch(text: String) {
        searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        loadPage(reset: true)
    }

    func didSelectSet(_ set: PublicSetModel) {
        router?.openPublicSetDetail(set)
    }

    func numberOfSets() -> Int { sets.count }
    func publicSet(at index: Int) -> PublicSetModel { sets[index] }

    func didPullToRefresh() {
        loadPage(reset: true)
    }

    func didRequestNextPage() {
        loadPage(reset: false)
    }

    private func sortParameter() -> String {
        switch selectedSort {
        case "Дата": return "recent"
        case "Количество карточек": return "cards_count"
        default: return "popular"
        }
    }

    private func refreshCategoryChips() {
        let titles = ["Все"] + categoryNameToId.keys.sorted()
        view?.setCategoryChips(titles: titles, selected: selectedCategory)
    }

    private func mergeCategoriesFromPublicDecks(_ decks: [PublicDeckListItemDTO]) {
        for d in decks {
            if let c = d.category {
                categoryNameToId[c.name] = c.id
            }
        }
        refreshCategoryChips()
    }

    private func categoryIdForFilter() -> Int? {
        guard selectedCategory != "Все" else { return nil }
        return categoryNameToId[selectedCategory]
    }

    private func loadPage(reset: Bool) {
        if !reset {
            if isLoading { return }
            if let p = lastPagination, p.page * p.limit >= p.total { return }
        } else {
            publicDecksLoadGeneration += 1
        }
        let generation = publicDecksLoadGeneration
        isLoading = true
        let page = reset ? 1 : (lastPagination?.page ?? 0) + 1
        if favoritesOnly {
            StudyContentService.shared.listFavorites(page: page, limit: 20) { [weak self] result in
                guard let self else { return }
                guard generation == self.publicDecksLoadGeneration else { return }
                self.isLoading = false
                switch result {
                case .failure(let error):
                    self.view?.showErrorToast(error.localizedDescription)
                case .success(let data):
                    self.lastPagination = data.pagination
                    let newItems: [PublicSetModel] = data.decks.map {
                        PublicSetModel(
                            id: "\($0.id)",
                            title: $0.title,
                            cardCount: $0.cardsCount,
                            category: $0.category?.name ?? "Без категории",
                            authorName: "Избранное",
                            authorAvatarURL: nil,
                            popularity: $0.cardsCount,
                            createdAt: Date()
                        )
                    }
                    if reset { self.sets = newItems } else { self.sets += newItems }
                    self.view?.reloadData()
                    self.view?.showEmptyState(self.sets.isEmpty)
                }
            }
            return
        }
        let search = searchText.isEmpty ? nil : searchText
        StudyContentService.shared.listPublicDecks(
            page: page,
            limit: 20,
            search: search,
            categoryId: categoryIdForFilter(),
            sortBy: sortParameter()
        ) { [weak self] result in
            guard let self else { return }
            guard generation == self.publicDecksLoadGeneration else { return }
            self.isLoading = false
            switch result {
            case .failure(let error):
                self.view?.showErrorToast(error.localizedDescription)
            case .success(let data):
                self.lastPagination = data.pagination
                let newItems = data.decks.map { StudyContentMappers.publicSet(from: $0) }
                if reset {
                    self.sets = newItems
                } else {
                    self.sets += newItems
                }
                self.mergeCategoriesFromPublicDecks(data.decks)
                self.view?.reloadData()
                self.view?.showEmptyState(self.sets.isEmpty)
            }
        }
    }
}
