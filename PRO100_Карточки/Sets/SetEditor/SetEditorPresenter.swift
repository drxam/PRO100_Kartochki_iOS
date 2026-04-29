//
//  SetEditorPresenter.swift
//  PRO100_Карточки
//

import Foundation

protocol SetEditorViewInput: AnyObject {
    /// `categoryPickTitles`: первый пункт — «Без категории», далее имена из `GET /categories`.
    func configure(title: String, saveTitle: String, draft: SetEditorDraft, categoryPickTitles: [String])
    func refreshCategoryChips(titles: [String], selectedCategory: String)
    func showError(_ message: String)
    func setLoading(_ isLoading: Bool)
}

protocol SetEditorViewOutput: AnyObject {
    func viewDidLoad()
    func didTapSave(draft: SetEditorDraft)
    func didTapCancel()
    /// Создание категории на сервере (`POST /api/categories`), затем обновление чипов.
    func didSubmitNewCategory(name: String)
}

struct SetEditorDraft {
    let title: String
    let description: String
    let category: String
    let tags: [String]
    let isPrivate: Bool
}

final class SetEditorPresenter {
    weak var view: SetEditorViewInput?
    var router: SetEditorRouterProtocol?
    private let mode: SetEditorMode

    init(mode: SetEditorMode) {
        self.mode = mode
    }
}

extension SetEditorPresenter: SetEditorViewOutput {
    func viewDidLoad() {
        StudyContentService.shared.fetchCategories { [weak self] result in
            guard let self else { return }
            let apiNames: [String] = {
                if case .success(let list) = result { return list.map(\.name) }
                return []
            }()
            var nameSet = Set(apiNames)
            nameSet.insert("Без категории")
            if case .edit(let set) = self.mode, set.category != "Без категории", !set.category.isEmpty {
                nameSet.insert(set.category)
            }
            let titles = ["Без категории"] + nameSet.filter { $0 != "Без категории" }.sorted()
            switch self.mode {
            case .create:
                self.view?.configure(
                    title: "Новый набор",
                    saveTitle: "Создать",
                    draft: SetEditorDraft(title: "", description: "", category: "Без категории", tags: [], isPrivate: false),
                    categoryPickTitles: titles
                )
            case .edit(let set):
                self.view?.configure(
                    title: "Редактирование набора",
                    saveTitle: "Сохранить",
                    draft: SetEditorDraft(
                        title: set.title,
                        description: set.description,
                        category: set.category,
                        tags: set.tags,
                        isPrivate: set.isPrivate
                    ),
                    categoryPickTitles: titles
                )
            }
        }
    }

    func didTapSave(draft: SetEditorDraft) {
        let cleanTitle = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            view?.showError("Название набора обязательно.")
            return
        }

        view?.setLoading(true)
        let desc = draft.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionPayload: String? = desc.isEmpty ? nil : desc
        let isPublic = !draft.isPrivate

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
                    if draft.category == "Без категории" { return nil }
                    return categories.first { $0.name == draft.category }?.id
                }()
                StudyContentService.shared.resolveTagIds(names: draft.tags, allTags: allTags) { tagRes in
                    switch tagRes {
                    case .failure(let error):
                        self.view?.setLoading(false)
                        self.view?.showError(error.localizedDescription)
                    case .success(let tagIds):
                        self.performSave(
                            cleanTitle: cleanTitle,
                            description: descriptionPayload,
                            isPublic: isPublic,
                            categoryId: categoryId,
                            tagIds: tagIds
                        )
                    }
                }
            }
        }
    }

    private func performSave(
        cleanTitle: String,
        description: String?,
        isPublic: Bool,
        categoryId: Int?,
        tagIds: [Int]
    ) {
        switch mode {
        case .create:
            StudyContentService.shared.createDeck(
                title: cleanTitle,
                description: description,
                isPublic: isPublic,
                categoryId: categoryId,
                tagIds: tagIds
            ) { [weak self] result in
                self?.view?.setLoading(false)
                switch result {
                case .failure(let error):
                    self?.view?.showError(error.localizedDescription)
                case .success:
                    self?.router?.close()
                }
            }
        case .edit(let set):
            guard let id = Int(set.id) else {
                view?.setLoading(false)
                view?.showError("Некорректный идентификатор набора.")
                return
            }
            StudyContentService.shared.updateDeck(
                id: id,
                title: cleanTitle,
                description: description,
                isPublic: isPublic,
                categoryId: categoryId,
                tagIds: tagIds
            ) { [weak self] result in
                self?.view?.setLoading(false)
                switch result {
                case .failure(let error):
                    self?.view?.showError(error.localizedDescription)
                case .success:
                    self?.router?.close()
                }
            }
        }
    }

    func didSubmitNewCategory(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            view?.showError("Введите название категории.")
            return
        }
        view?.setLoading(true)
        StudyContentService.shared.createCategory(name: trimmed) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                self.view?.setLoading(false)
                self.view?.showError(error.localizedDescription)
            case .success:
                StudyContentService.shared.fetchCategories { [weak self] res in
                    guard let self else { return }
                    self.view?.setLoading(false)
                    let apiNames: [String] = {
                        if case .success(let list) = res { return list.map(\.name) }
                        return []
                    }()
                    var nameSet = Set(apiNames)
                    nameSet.insert("Без категории")
                    if case .edit(let set) = self.mode, set.category != "Без категории", !set.category.isEmpty {
                        nameSet.insert(set.category)
                    }
                    nameSet.insert(trimmed)
                    let titles = ["Без категории"] + nameSet.filter { $0 != "Без категории" }.sorted()
                    self.view?.refreshCategoryChips(titles: titles, selectedCategory: trimmed)
                }
            }
        }
    }

    func didTapCancel() {
        router?.close()
    }
}
