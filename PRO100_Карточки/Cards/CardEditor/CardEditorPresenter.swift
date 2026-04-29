//
//  CardEditorPresenter.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - CardEditorViewInput
protocol CardEditorViewInput: AnyObject {
    func configure(
        title: String,
        saveTitle: String,
        draft: CardEditorDraft,
        sets: [CardSetModel],
        lockedSetId: String?,
        categoryPickTitles: [String],
        usesDeckCategory: Bool
    )
    func showError(_ message: String)
    func setLoading(_ isLoading: Bool)
}

// MARK: - CardEditorViewOutput
protocol CardEditorViewOutput: AnyObject {
    func viewDidLoad()
    func didTapSave(draft: CardEditorDraft)
    func didTapCancel()
}

// MARK: - CardEditorDraft
struct CardEditorDraft {
    let question: String
    let answer: String
    let category: String
    let tags: [String]
    let setId: String?
    let resolvedCategoryId: Int?
}

// MARK: - CardEditorPresenter
final class CardEditorPresenter {
    weak var view: CardEditorViewInput?
    var router: CardEditorRouterProtocol?
    private let mode: CardEditorMode

    init(mode: CardEditorMode) {
        self.mode = mode
    }
}

// MARK: - CardEditorPresenter Extension
extension CardEditorPresenter: CardEditorViewOutput {
    func viewDidLoad() {
        switch mode {
        case .create(let prefilledSetId):
            if let prefilledSetId, let deckId = Int(prefilledSetId) {
                StudyContentService.shared.getMyDeck(id: deckId) { [weak self] result in
                    guard let self else { return }
                    let (catName, catId): (String, Int?) = {
                        if case .success(let dto) = result, let c = dto.category {
                            return (c.name, c.id)
                        }
                        return ("Без категории", nil)
                    }()
                    self.view?.configure(
                        title: "Новая карточка",
                        saveTitle: "Создать",
                        draft: CardEditorDraft(
                            question: "",
                            answer: "",
                            category: catName,
                            tags: [],
                            setId: prefilledSetId,
                            resolvedCategoryId: catId
                        ),
                        sets: [],
                        lockedSetId: prefilledSetId,
                        categoryPickTitles: [],
                        usesDeckCategory: true
                    )
                }
                return
            }
            StudyContentService.shared.listMyDecks(page: 1, limit: 100, search: nil, categoryId: nil) { [weak self] result in
                guard let self else { return }
                let sets: [CardSetModel] = {
                    if case .success(let data) = result {
                        return data.decks.map { StudyContentMappers.cardSet(from: $0) }
                    }
                    return []
                }()
                StudyContentService.shared.fetchCategories { [weak self] cRes in
                    guard let self else { return }
                    let titles = Self.categoryTitles(from: cRes)
                    self.view?.configure(
                        title: "Новая карточка",
                        saveTitle: "Создать",
                        draft: CardEditorDraft(
                            question: "",
                            answer: "",
                            category: "Без категории",
                            tags: [],
                            setId: sets.first.map(\.id),
                            resolvedCategoryId: nil
                        ),
                        sets: sets,
                        lockedSetId: nil,
                        categoryPickTitles: titles,
                        usesDeckCategory: false
                    )
                }
            }
        case .edit(let card):
            func presentEdit(with source: CardModel, sets: [CardSetModel]) {
                StudyContentService.shared.fetchCategories { [weak self] cRes in
                    guard let self else { return }
                    let apiNames = (try? cRes.get())?.map(\.name) ?? []
                    var nameSet = Set(apiNames)
                    nameSet.insert("Без категории")
                    if source.category != "Без категории", !source.category.isEmpty {
                        nameSet.insert(source.category)
                    }
                    let titles = ["Без категории"] + nameSet.filter { $0 != "Без категории" }.sorted()
                    self.view?.configure(
                        title: "Редактирование карточки",
                        saveTitle: "Сохранить",
                        draft: CardEditorDraft(
                            question: source.question,
                            answer: source.answer,
                            category: source.category,
                            tags: source.tags,
                            setId: source.setId,
                            resolvedCategoryId: nil
                        ),
                        sets: sets,
                        lockedSetId: nil,
                        categoryPickTitles: titles,
                        usesDeckCategory: false
                    )
                }
            }
            StudyContentService.shared.listMyDecks(page: 1, limit: 100, search: nil, categoryId: nil) { [weak self] result in
                guard let self else { return }
                let sets: [CardSetModel] = {
                    if case .success(let data) = result {
                        return data.decks.map { StudyContentMappers.cardSet(from: $0) }
                    }
                    return []
                }()
                guard let cardId = Int(card.id) else {
                    presentEdit(with: card, sets: sets)
                    return
                }
                StudyContentService.shared.getMyCard(id: cardId) { itemResult in
                    let source: CardModel = {
                        if case .success(let dto) = itemResult {
                            return StudyContentMappers.cardModel(from: dto)
                        }
                        return card
                    }()
                    presentEdit(with: source, sets: sets)
                }
            }
        }
    }

    func didTapSave(draft: CardEditorDraft) {
        let question = draft.question.trimmingCharacters(in: .whitespacesAndNewlines)
        let answer = draft.answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else {
            view?.showError("Вопрос обязателен.")
            return
        }
        guard !answer.isEmpty else {
            view?.showError("Ответ обязателен.")
            return
        }
        guard let setId = draft.setId, let deckId = Int(setId) else {
            view?.showError("Выберите набор.")
            return
        }

        view?.setLoading(true)
        StudyContentService.shared.fetchCategories { [weak self] cRes in
            guard let self else { return }
            let categories: [APICategory] = {
                if case .success(let c) = cRes { return c }
                return []
            }()
            StudyContentService.shared.fetchTags { tRes in
                let allTags: [APITag] = {
                    if case .success(let t) = tRes { return t }
                    return []
                }()
                let categoryId: Int? = {
                    if let r = draft.resolvedCategoryId { return r }
                    if draft.category == "Без категории" { return nil }
                    return categories.first { $0.name == draft.category }?.id
                }()
                StudyContentService.shared.resolveTagIds(names: draft.tags, allTags: allTags) { tagRes in
                    switch tagRes {
                    case .failure(let error):
                        self.view?.setLoading(false)
                        self.view?.showError(error.localizedDescription)
                    case .success(let tagIds):
                        self.saveCard(
                            deckId: deckId,
                            question: question,
                            answer: answer,
                            categoryId: categoryId,
                            tagIds: tagIds
                        )
                    }
                }
            }
        }
    }

    private func saveCard(
        deckId: Int,
        question: String,
        answer: String,
        categoryId: Int?,
        tagIds: [Int]
    ) {
        switch mode {
        case .create:
            StudyContentService.shared.createCardInDeck(
                deckId: deckId,
                question: question,
                answer: answer,
                categoryId: categoryId,
                tagIds: tagIds
            ) { [weak self] result in
                self?.view?.setLoading(false)
                switch result {
                case .failure(let e):
                    self?.view?.showError(e.localizedDescription)
                case .success:
                    self?.router?.close()
                }
            }
        case .edit(let card):
            guard let id = Int(card.id) else {
                view?.setLoading(false)
                view?.showError("Некорректный id карточки.")
                return
            }
            let oldSetId = Int(card.setId) ?? 0
            if oldSetId == deckId {
                StudyContentService.shared.updateCard(
                    id: id,
                    question: question,
                    answer: answer,
                    categoryId: categoryId,
                    tagIds: tagIds
                ) { [weak self] result in
                    self?.view?.setLoading(false)
                    switch result {
                    case .failure(let e):
                        self?.view?.showError(e.localizedDescription)
                    case .success:
                        self?.router?.close()
                    }
                }
            } else {
                StudyContentService.shared.deleteCard(id: id) { [weak self] delRes in
                    guard let self else { return }
                    if case .failure(let e) = delRes {
                        self.view?.setLoading(false)
                        self.view?.showError(e.localizedDescription)
                        return
                    }
                    StudyContentService.shared.createCardInDeck(
                        deckId: deckId,
                        question: question,
                        answer: answer,
                        categoryId: categoryId,
                        tagIds: tagIds
                    ) { [weak self] result in
                        self?.view?.setLoading(false)
                        switch result {
                        case .failure(let e):
                            self?.view?.showError(e.localizedDescription)
                        case .success:
                            self?.router?.close()
                        }
                    }
                }
            }
        }
    }

    func didTapCancel() {
        router?.close()
    }

    private static func categoryTitles(from result: Result<[APICategory], AuthError>) -> [String] {
        let names: [String] = {
            if case .success(let list) = result { return list.map(\.name) }
            return []
        }()
        var set = Set(names)
        set.insert("Без категории")
        return ["Без категории"] + set.filter { $0 != "Без категории" }.sorted()
    }
}
