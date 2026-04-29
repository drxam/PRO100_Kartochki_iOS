//
//  SetsListPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class SetsListPresenter {
    weak var view: SetsListViewInput?
    var router: SetsListRouterProtocol?
    private var sets: [CardSetModel] = []
    private var allCategories: [APICategory] = []
    /// Имена категорий → id (из `GET /categories` и из полей `category` в ответах наборов).
    private var categoryNameToId: [String: Int] = [:]
    private var selectedCategory = "Все"
    private var searchText = ""
    private var lastPagination: PaginationDTO?
    private var isLoading = false
    private var decksLoadGeneration = 0
}

extension SetsListPresenter: SetsListViewOutput {
    func viewDidLoad() {
        categoryNameToId = [:]
        selectedCategory = "Все"
        refreshCategoryChips()
        loadDecks(reset: true)
    }

    func viewWillAppear() {
        loadDecks(reset: true)
    }

    func didTapAdd() {
        router?.openCreateSet()
    }

    func didSelectSet(_ set: CardSetModel) {
        router?.openSetDetail(set)
    }

    func didSelectCategory(_ category: String) {
        selectedCategory = category
        loadDecks(reset: true)
    }

    func didSearch(text: String) {
        searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        loadDecks(reset: true)
    }

    func numberOfSets() -> Int {
        sets.count
    }

    func set(at index: Int) -> CardSetModel {
        sets[index]
    }

    func didPullToRefresh() {
        loadDecks(reset: true)
    }

    func didRequestNextPage() {
        loadDecks(reset: false)
    }

    private func refreshCategoryChips() {
        let titles = ["Все"] + categoryNameToId.keys.sorted()
        view?.setCategoryChips(titles: titles, selected: selectedCategory)
    }

    private func mergeCategoriesFromDecks(_ decks: [DeckListItemDTO]) {
        for d in decks {
            if let c = d.category {
                categoryNameToId[c.name] = c.id
            }
        }
        if selectedCategory != "Все", categoryNameToId[selectedCategory] == nil {
            selectedCategory = "Все"
        }
        refreshCategoryChips()
    }

    private func categoryIdForFilter() -> Int? {
        guard selectedCategory != "Все" else { return nil }
        return categoryNameToId[selectedCategory]
    }

    private func loadDecks(reset: Bool) {
        if !reset {
            if isLoading { return }
            if let p = lastPagination, p.page * p.limit >= p.total { return }
        } else {
            decksLoadGeneration += 1
        }
        let generation = decksLoadGeneration
        isLoading = true
        let page: Int
        if reset {
            page = 1
        } else {
            page = (lastPagination?.page ?? 0) + 1
        }
        let search = searchText.isEmpty ? nil : searchText
        StudyContentService.shared.listMyDecks(
            page: page,
            limit: 20,
            search: search,
            categoryId: categoryIdForFilter()
        ) { [weak self] result in
            guard let self else { return }
            guard generation == self.decksLoadGeneration else { return }
            self.isLoading = false
            self.view?.reloadData()
            switch result {
            case .failure(let error):
                self.view?.showErrorToast(error.localizedDescription)
            case .success(let data):
                self.lastPagination = data.pagination
                let newItems = data.decks.map { StudyContentMappers.cardSet(from: $0) }
                if reset {
                    self.categoryNameToId = [:]
                    self.sets = newItems
                } else {
                    self.sets += newItems
                }
                self.mergeCategoriesFromDecks(data.decks)
                self.view?.reloadData()
                self.view?.showEmptyState(self.sets.isEmpty)
            }
        }
    }
}
