//
//  CardEditorViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - CardEditorViewController
final class CardEditorViewController: UIViewController {
    var output: CardEditorViewOutput?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let questionView = UITextView()
    private let answerView = UITextView()
    private let categoryColumn = UIStackView()
    private let inheritedCategoryLabel = UILabel()
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private var categoryButtons: [String: UIButton] = [:]
    private var selectedCategory = "Без категории"
    private var categoryTitleForSave = "Без категории"
    private var usesDeckCategory = false
    private var inheritedCategoryId: Int?
    private let setControl = UISegmentedControl(items: [])
    private let tagInput = UITextField()
    private let addTagButton = UIButton(type: .system)
    private let tagSuggestPanel = CardEditorTagSuggestPanel()
    private var tagSuggestHeightConstraint: NSLayoutConstraint!
    private var collapseTagSuggestWorkItem: DispatchWorkItem?
    private let tagsStack = UIStackView()
    private let errorLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var setIds: [String] = []
    private var tags: [String] = []
    private var lockedSetId: String?

    private var tagInputTopBelowSetConstraint: NSLayoutConstraint!
    private var tagInputTopBelowCategoryConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Создать", style: .done, target: self, action: #selector(saveTapped))

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        questionView.font = .systemFont(ofSize: 16)
        questionView.layer.borderColor = UIColor.systemGray5.cgColor
        questionView.layer.borderWidth = 1
        questionView.layer.cornerRadius = 8
        questionView.text = "Введите вопрос или термин"
        questionView.textColor = .secondaryLabel
        questionView.delegate = self
        questionView.translatesAutoresizingMaskIntoConstraints = false

        answerView.font = .systemFont(ofSize: 16)
        answerView.layer.borderColor = UIColor.systemGray5.cgColor
        answerView.layer.borderWidth = 1
        answerView.layer.cornerRadius = 8
        answerView.text = "Введите ответ или определение"
        answerView.textColor = .secondaryLabel
        answerView.delegate = self
        answerView.translatesAutoresizingMaskIntoConstraints = false

        categoryColumn.axis = .vertical
        categoryColumn.spacing = 6
        categoryColumn.translatesAutoresizingMaskIntoConstraints = false

        inheritedCategoryLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        inheritedCategoryLabel.textColor = .secondaryLabel
        inheritedCategoryLabel.numberOfLines = 0
        inheritedCategoryLabel.translatesAutoresizingMaskIntoConstraints = false

        categoryScroll.showsHorizontalScrollIndicator = false
        categoryScroll.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.axis = .horizontal
        categoryStack.spacing = 8
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.addSubview(categoryStack)

        categoryColumn.addArrangedSubview(inheritedCategoryLabel)
        categoryColumn.addArrangedSubview(categoryScroll)
        categoryScroll.heightAnchor.constraint(equalToConstant: 44).isActive = true

        setControl.translatesAutoresizingMaskIntoConstraints = false

        tagInput.placeholder = "Тег"
        tagInput.borderStyle = .roundedRect
        tagInput.autocorrectionType = .no
        tagInput.autocapitalizationType = .none
        tagInput.returnKeyType = .done
        tagInput.delegate = self
        tagInput.addTarget(self, action: #selector(tagInputEditingChanged), for: .editingChanged)
        tagInput.translatesAutoresizingMaskIntoConstraints = false

        addTagButton.setTitle("Добавить", for: .normal)
        addTagButton.addTarget(self, action: #selector(addTagTapped), for: .touchUpInside)
        addTagButton.translatesAutoresizingMaskIntoConstraints = false

        tagSuggestPanel.translatesAutoresizingMaskIntoConstraints = false
        tagSuggestPanel.isHidden = true
        tagSuggestPanel.tagsAlreadyOnCard = { [weak self] in self?.tags ?? [] }
        tagSuggestPanel.onPick = { [weak self] name in
            self?.cancelCollapseTagSuggestPanel()
            self?.applyTagNameIfNew(name)
            self?.tagInput.text = ""
            self?.tagSuggestPanel.setFilterText("")
            self?.refreshTagSuggestPanelHeight(animated: true)
        }
        tagSuggestPanel.onNeedsLayoutUpdate = { [weak self] in
            self?.refreshTagSuggestPanelHeight(animated: false)
        }

        tagsStack.axis = .vertical
        tagsStack.spacing = 8
        tagsStack.translatesAutoresizingMaskIntoConstraints = false

        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        [questionView, answerView, categoryColumn, setControl, tagInput, addTagButton, tagSuggestPanel, tagsStack, errorLabel, activityIndicator].forEach {
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            questionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            questionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            questionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            questionView.heightAnchor.constraint(equalToConstant: 120),

            answerView.topAnchor.constraint(equalTo: questionView.bottomAnchor, constant: 12),
            answerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            answerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            answerView.heightAnchor.constraint(equalToConstant: 120),

            categoryColumn.topAnchor.constraint(equalTo: answerView.bottomAnchor, constant: 12),
            categoryColumn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryColumn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            setControl.topAnchor.constraint(equalTo: categoryColumn.bottomAnchor, constant: 12),
            setControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            setControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        tagInputTopBelowSetConstraint = tagInput.topAnchor.constraint(equalTo: setControl.bottomAnchor, constant: 12)
        tagInputTopBelowCategoryConstraint = tagInput.topAnchor.constraint(equalTo: categoryColumn.bottomAnchor, constant: 12)
        tagInputTopBelowCategoryConstraint.isActive = false

        NSLayoutConstraint.activate([
            tagInputTopBelowSetConstraint,
            tagInput.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagInput.trailingAnchor.constraint(equalTo: addTagButton.leadingAnchor, constant: -8),
            tagInput.heightAnchor.constraint(equalToConstant: 44),

            addTagButton.centerYAnchor.constraint(equalTo: tagInput.centerYAnchor),
            addTagButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            tagSuggestPanel.topAnchor.constraint(equalTo: tagInput.bottomAnchor, constant: 4),
            tagSuggestPanel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagSuggestPanel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            tagsStack.topAnchor.constraint(equalTo: tagSuggestPanel.bottomAnchor, constant: 8),
            tagsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            errorLabel.topAnchor.constraint(equalTo: tagsStack.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            activityIndicator.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor, constant: 16),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -16),
            categoryStack.topAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.topAnchor),
            categoryStack.bottomAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.bottomAnchor),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),
        ])

        tagSuggestHeightConstraint = tagSuggestPanel.heightAnchor.constraint(equalToConstant: 0)
        tagSuggestHeightConstraint.isActive = true
    }

    private func applySetPickerVisibility(lockedSetId: String?) {
        self.lockedSetId = lockedSetId
        let locked = lockedSetId != nil
        setControl.isHidden = locked
        tagInputTopBelowSetConstraint.isActive = !locked
        tagInputTopBelowCategoryConstraint.isActive = locked
    }

    private func buildCategoryChips(titles: [String]) {
        categoryStack.arrangedSubviews.forEach {
            categoryStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        categoryButtons.removeAll()
        let list = titles.isEmpty ? ["Без категории"] : titles
        for name in list {
            let btn = UIButton(type: .system)
            btn.setTitle(name, for: .normal)
            btn.layer.cornerRadius = 16
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            btn.addTarget(self, action: #selector(categoryChipTapped(_:)), for: .touchUpInside)
            btn.setTitleColor(.label, for: .normal)
            btn.backgroundColor = .secondarySystemFill
            categoryStack.addArrangedSubview(btn)
            categoryButtons[name] = btn
        }
        refreshCategoryChipStyles()
    }

    private func refreshCategoryChipStyles() {
        for (name, btn) in categoryButtons {
            let on = (name == selectedCategory)
            btn.backgroundColor = on ? AppConstants.accentColor : .secondarySystemFill
            btn.setTitleColor(on ? .white : .label, for: .normal)
        }
    }

    @objc private func categoryChipTapped(_ sender: UIButton) {
        selectedCategory = sender.title(for: .normal) ?? selectedCategory
        categoryTitleForSave = selectedCategory
        refreshCategoryChipStyles()
    }

    @objc private func saveTapped() {
        let setId: String? = {
            if let lockedSetId { return lockedSetId }
            guard setControl.selectedSegmentIndex >= 0, setControl.selectedSegmentIndex < setIds.count else { return nil }
            return setIds[setControl.selectedSegmentIndex]
        }()
        output?.didTapSave(
            draft: CardEditorDraft(
                question: questionView.textColor == .secondaryLabel ? "" : questionView.text,
                answer: answerView.textColor == .secondaryLabel ? "" : answerView.text,
                category: categoryTitleForSave,
                tags: tags,
                setId: setId,
                resolvedCategoryId: usesDeckCategory ? inheritedCategoryId : nil
            )
        )
    }

    @objc private func cancelTapped() {
        output?.didTapCancel()
    }

    @objc private func addTagTapped() {
        let tag = (tagInput.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        applyTagNameIfNew(tag)
        tagInput.text = ""
        if tagInput.isFirstResponder {
            tagSuggestPanel.setFilterText("")
            refreshTagSuggestPanelHeight(animated: true)
        }
    }

    private func applyTagNameIfNew(_ tag: String) {
        let t = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        if !tags.contains(where: { $0.caseInsensitiveCompare(t) == .orderedSame }) {
            tags.append(t)
            renderTags()
        }
    }

    private func showTagSuggestPanel() {
        cancelCollapseTagSuggestPanel()
        tagSuggestPanel.isHidden = false
        tagSuggestPanel.prepareForDisplay()
        tagSuggestPanel.setFilterText(tagInput.text ?? "")
        refreshTagSuggestPanelHeight(animated: true)
        scrollTagInputIntoViewIfNeeded()
    }

    private func scheduleHideTagSuggestPanel() {
        cancelCollapseTagSuggestPanel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.tagSuggestHeightConstraint.constant = 0
            self.tagSuggestPanel.isHidden = true
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        collapseTagSuggestWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22, execute: work)
    }

    private func cancelCollapseTagSuggestPanel() {
        collapseTagSuggestWorkItem?.cancel()
        collapseTagSuggestWorkItem = nil
    }

    private func refreshTagSuggestPanelHeight(animated: Bool) {
        guard tagInput.isFirstResponder else { return }
        let h = tagSuggestPanel.preferredHeight()
        tagSuggestHeightConstraint.constant = h
        let updates = {
            self.view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }
    }

    private func scrollTagInputIntoViewIfNeeded() {
        let rectInScroll = tagInput.convert(tagInput.bounds.insetBy(dx: 0, dy: -8), to: scrollView)
        scrollView.scrollRectToVisible(rectInScroll, animated: true)
    }

    @objc private func tagInputEditingChanged() {
        tagSuggestPanel.setFilterText(tagInput.text ?? "")
        refreshTagSuggestPanelHeight(animated: false)
    }

    private func renderTags() {
        tagsStack.arrangedSubviews.forEach {
            tagsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for tag in tags {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .equalSpacing
            let label = UILabel()
            label.text = "• \(tag)"
            let removeButton = UIButton(type: .system)
            removeButton.setTitle("Удалить", for: .normal)
            removeButton.addAction(UIAction { [weak self] _ in
                self?.tags.removeAll { $0 == tag }
                self?.renderTags()
            }, for: .touchUpInside)
            row.addArrangedSubview(label)
            row.addArrangedSubview(removeButton)
            tagsStack.addArrangedSubview(row)
        }
        if tagInput.isFirstResponder {
            tagSuggestPanel.setFilterText(tagInput.text ?? "")
            refreshTagSuggestPanelHeight(animated: false)
        }
    }
}

// MARK: - CardEditorViewController Extension
extension CardEditorViewController: CardEditorViewInput {
    func configure(
        title: String,
        saveTitle: String,
        draft: CardEditorDraft,
        sets: [CardSetModel],
        lockedSetId: String?,
        categoryPickTitles: [String],
        usesDeckCategory: Bool
    ) {
        self.title = title
        navigationItem.rightBarButtonItem?.title = saveTitle
        applySetPickerVisibility(lockedSetId: lockedSetId)

        self.usesDeckCategory = usesDeckCategory
        self.inheritedCategoryId = draft.resolvedCategoryId
        inheritedCategoryLabel.isHidden = !usesDeckCategory
        categoryScroll.isHidden = usesDeckCategory
        if usesDeckCategory {
            inheritedCategoryLabel.text = "Категория как у набора: \(draft.category)"
            categoryTitleForSave = draft.category
        } else {
            let titles = categoryPickTitles.isEmpty ? ["Без категории"] : categoryPickTitles
            if titles.contains(draft.category) {
                selectedCategory = draft.category
            } else {
                selectedCategory = titles.first ?? "Без категории"
            }
            categoryTitleForSave = selectedCategory
            buildCategoryChips(titles: titles)
        }

        if draft.question.isEmpty {
            questionView.text = "Введите вопрос или термин"
            questionView.textColor = .secondaryLabel
        } else {
            questionView.text = draft.question
            questionView.textColor = .label
        }

        if draft.answer.isEmpty {
            answerView.text = "Введите ответ или определение"
            answerView.textColor = .secondaryLabel
        } else {
            answerView.text = draft.answer
            answerView.textColor = .label
        }

        setIds = sets.map(\.id)
        setControl.removeAllSegments()
        for (idx, set) in sets.enumerated() {
            setControl.insertSegment(withTitle: set.title, at: idx, animated: false)
        }
        if lockedSetId == nil {
            if let setId = draft.setId, let idx = setIds.firstIndex(of: setId) {
                setControl.selectedSegmentIndex = idx
            } else if !setIds.isEmpty {
                setControl.selectedSegmentIndex = 0
            }
        }

        tags = draft.tags
        renderTags()
    }

    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = message.isEmpty
        if !message.isEmpty {
            showTopBanner(message)
        }
    }

    func setLoading(_ isLoading: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = !isLoading
        navigationItem.leftBarButtonItem?.isEnabled = !isLoading
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

// MARK: - CardEditorViewController Extension
extension CardEditorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField == tagInput else { return }
        DispatchQueue.main.async { [weak self] in
            self?.showTagSuggestPanel()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == tagInput else { return }
        scheduleHideTagSuggestPanel()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagInput {
            addTagTapped()
            return true
        }
        return true
    }
}

// MARK: - CardEditorViewController Extension
extension CardEditorViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if textView == questionView {
                textView.text = "Введите вопрос или термин"
            } else {
                textView.text = "Введите ответ или определение"
            }
            textView.textColor = .secondaryLabel
        }
    }
}
