//
//  CardsListPresenter.swift
//  PRO100_Карточки
//

import Foundation

final class CardsListPresenter {
    weak var view: CardsListViewInput?
    var router: CardsListRouterProtocol?
    private var cards: [CardModel] = []
    private var allCategories: [APICategory] = []
    private var categoryNameToId: [String: Int] = [:]
    private var allTagNames: [String] = []
    private var tagNameToId: [String: Int] = [:]
    private var selectedCategory = "Все"
    private var selectedTag: String?
    private var searchText = ""
    private var lastPagination: PaginationDTO?
    /// Параллельные запросы (сброс + первая страница): считаем, чтобы completion «старого» запроса не залипал в `isLoading == true`.
    private var activeListRequests = 0
    private var isListLoading: Bool { activeListRequests > 0 }
    /// Смена фильтра во время уже идущей загрузки — ответы с устаревшим поколением не трогают список.
    private var cardsLoadGeneration = 0
    /// `viewDidLoad` уже делает первую загрузку; без этого `viewWillAppear` дублирует запрос и поднимает поколение лишний раз.
    private var hasSkippedFirstWillAppear = false
}

extension CardsListPresenter: CardsListViewOutput {
    func viewDidLoad() {
        categoryNameToId = [:]
        allTagNames = []
        tagNameToId = [:]
        selectedCategory = "Все"
        selectedTag = nil
        refreshCategoryChips()
        loadPage(reset: true)
    }

    func viewWillAppear() {
        if !hasSkippedFirstWillAppear {
            hasSkippedFirstWillAppear = true
            return
        }
        loadPage(reset: true)
    }

    func didTapAdd() {
        router?.openCreateCard()
    }

    func didSelectCard(at index: Int) {
        router?.openCardDetail(cards: cards, selectedIndex: index)
    }

    func didSelectCategory(_ category: String) {
        selectedCategory = category
        loadPage(reset: true)
    }

    func tagFilterPicked(_ tag: APITag?) {
        if let t = tag {
            selectedTag = t.name
            tagNameToId[t.name] = t.id
            allTagNames = tagNameToId.keys.sorted()
        } else {
            selectedTag = nil
        }
        loadPage(reset: true)
    }

    func didSearch(text: String) {
        searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        loadPage(reset: true)
    }

    func numberOfCards() -> Int { cards.count }
    func card(at index: Int) -> CardModel { cards[index] }

    func didPullToRefresh() {
        loadPage(reset: true)
    }

    func didRequestNextPage() {
        loadPage(reset: false)
    }

    func didTapTagFilter() {
        view?.presentTagPicker(selectedName: selectedTag) { [weak self] tag in
            self?.tagFilterPicked(tag)
        }
    }

    private func refreshCategoryChips() {
        let titles = ["Все"] + categoryNameToId.keys.sorted()
        view?.setCategoryChips(titles: titles, selected: selectedCategory)
    }

    private func mergeCategoriesFromCards(_ items: [CardListItemDTO]) {
        for item in items {
            if let c = item.category {
                categoryNameToId[c.name] = c.id
            }
        }
        refreshCategoryChips()
    }

    /// Теги с id из ответа списка карточек — чтобы фильтр работал, даже если `GET /tags` недоступен или в другом формате.
    private func mergeTagsFromCards(_ items: [CardListItemDTO]) {
        for item in items {
            for t in item.tags ?? [] {
                tagNameToId[t.name] = t.id
            }
        }
        allTagNames = tagNameToId.keys.sorted()
    }

    private func categoryIdForFilter() -> Int? {
        guard selectedCategory != "Все" else { return nil }
        return categoryNameToId[selectedCategory]
    }

    private func tagIdForFilter() -> Int? {
        let raw = selectedTag?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !raw.isEmpty else { return nil }
        if let id = tagNameToId[raw] { return id }
        let lower = raw.lowercased()
        return tagNameToId.first { $0.key.lowercased() == lower }?.value
    }

    private func loadPage(reset: Bool) {
        if !reset {
            if isListLoading { return }
            if let p = lastPagination, p.page * p.limit >= p.total { return }
        } else {
            cardsLoadGeneration += 1
        }
        let generation = cardsLoadGeneration
        activeListRequests += 1
        let page = reset ? 1 : (lastPagination?.page ?? 0) + 1
        let search = searchText.isEmpty ? nil : searchText
        StudyContentService.shared.listMyCards(
            page: page,
            limit: 20,
            search: search,
            categoryId: categoryIdForFilter(),
            tagId: tagIdForFilter()
        ) { [weak self] result in
            guard let self else { return }
            self.activeListRequests -= 1
            guard generation == self.cardsLoadGeneration else { return }
            switch result {
            case .failure(let error):
                self.view?.showErrorToast(error.localizedDescription)
                self.view?.reloadData()
            case .success(let data):
                self.lastPagination = data.pagination
                let newItems = data.cards.map { StudyContentMappers.cardModel(from: $0) }
                if reset {
                    self.cards = newItems
                } else {
                    self.cards += newItems
                }
                self.mergeCategoriesFromCards(data.cards)
                self.mergeTagsFromCards(data.cards)
                self.view?.showEmptyState(self.cards.isEmpty)
                self.view?.reloadData()
            }
        }
    }
}
