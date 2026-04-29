//
//  SetEditorViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - SetEditorViewController
final class SetEditorViewController: UIViewController {
    var output: SetEditorViewOutput?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleField = UITextField()
    private let descriptionView = UITextView()
    private let categoryHeaderStack = UIStackView()
    private let categoryHeadingLabel = UILabel()
    private let addCategoryButton = UIButton(type: .system)
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private var categoryButtons: [String: UIButton] = [:]
    private var selectedCategory = "Без категории"
    private let tagInputField = UITextField()
    private let addTagButton = UIButton(type: .system)
    private let tagsStack = UIStackView()
    private let publicSwitch = UISwitch()
    private let errorLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var tags: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTapped))

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        titleField.placeholder = "Название набора *"
        titleField.borderStyle = .roundedRect
        titleField.translatesAutoresizingMaskIntoConstraints = false

        descriptionView.layer.borderColor = UIColor.systemGray5.cgColor
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.cornerRadius = 8
        descriptionView.font = .systemFont(ofSize: 16)
        descriptionView.translatesAutoresizingMaskIntoConstraints = false

        categoryHeadingLabel.text = "Категория"
        categoryHeadingLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        categoryHeadingLabel.textColor = .secondaryLabel
        categoryHeadingLabel.translatesAutoresizingMaskIntoConstraints = false

        addCategoryButton.setTitle("Новая категория", for: .normal)
        addCategoryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addCategoryButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        addCategoryButton.setContentHuggingPriority(.required, for: .horizontal)
        addCategoryButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false

        categoryHeaderStack.axis = .horizontal
        categoryHeaderStack.alignment = .center
        categoryHeaderStack.spacing = 8
        categoryHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        let categoryHeaderSpacer = UIView()
        categoryHeaderSpacer.translatesAutoresizingMaskIntoConstraints = false
        categoryHeaderSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        categoryHeaderStack.addArrangedSubview(categoryHeadingLabel)
        categoryHeaderStack.addArrangedSubview(categoryHeaderSpacer)
        categoryHeaderStack.addArrangedSubview(addCategoryButton)

        categoryScroll.showsHorizontalScrollIndicator = false
        categoryScroll.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.axis = .horizontal
        categoryStack.spacing = 8
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.addSubview(categoryStack)

        tagInputField.placeholder = "Тег"
        tagInputField.borderStyle = .roundedRect
        tagInputField.translatesAutoresizingMaskIntoConstraints = false

        addTagButton.setTitle("Добавить тег", for: .normal)
        addTagButton.addTarget(self, action: #selector(addTagTapped), for: .touchUpInside)
        addTagButton.translatesAutoresizingMaskIntoConstraints = false

        tagsStack.axis = .vertical
        tagsStack.spacing = 8
        tagsStack.translatesAutoresizingMaskIntoConstraints = false

        let privacyRow = UIStackView()
        privacyRow.axis = .horizontal
        privacyRow.alignment = .center
        privacyRow.distribution = .equalSpacing
        privacyRow.translatesAutoresizingMaskIntoConstraints = false
        let privacyLabel = UILabel()
        privacyLabel.text = "Публичный набор"
        privacyRow.addArrangedSubview(privacyLabel)
        privacyRow.addArrangedSubview(publicSwitch)

        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        [titleField, descriptionView, categoryHeaderStack, categoryScroll, tagInputField, addTagButton, tagsStack, privacyRow, errorLabel, activityIndicator].forEach {
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

            titleField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleField.heightAnchor.constraint(equalToConstant: 44),

            descriptionView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 12),
            descriptionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionView.heightAnchor.constraint(equalToConstant: 120),

            categoryHeaderStack.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 12),
            categoryHeaderStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryHeaderStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            categoryScroll.topAnchor.constraint(equalTo: categoryHeaderStack.bottomAnchor, constant: 6),
            categoryScroll.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryScroll.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryScroll.heightAnchor.constraint(equalToConstant: 44),
            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor, constant: 16),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -16),
            categoryStack.topAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.topAnchor),
            categoryStack.bottomAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.bottomAnchor),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),

            tagInputField.topAnchor.constraint(equalTo: categoryScroll.bottomAnchor, constant: 12),
            tagInputField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagInputField.trailingAnchor.constraint(equalTo: addTagButton.leadingAnchor, constant: -8),
            tagInputField.heightAnchor.constraint(equalToConstant: 44),

            addTagButton.centerYAnchor.constraint(equalTo: tagInputField.centerYAnchor),
            addTagButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            tagsStack.topAnchor.constraint(equalTo: tagInputField.bottomAnchor, constant: 8),
            tagsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            privacyRow.topAnchor.constraint(equalTo: tagsStack.bottomAnchor, constant: 16),
            privacyRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            privacyRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            errorLabel.topAnchor.constraint(equalTo: privacyRow.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            activityIndicator.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    @objc private func saveTapped() {
        output?.didTapSave(
            draft: SetEditorDraft(
                title: titleField.text ?? "",
                description: descriptionView.text ?? "",
                category: selectedCategory,
                tags: tags,
                isPrivate: !publicSwitch.isOn
            )
        )
    }

    @objc private func categoryChipTapped(_ sender: UIButton) {
        selectedCategory = sender.title(for: .normal) ?? selectedCategory
        refreshCategoryChipStyles()
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

    @objc private func cancelTapped() {
        output?.didTapCancel()
    }

    @objc private func addCategoryTapped() {
        let alert = UIAlertController(
            title: "Новая категория",
            message: "Категории в базе изначально пустые: их создают пользователи или админ. После создания она появится здесь и в фильтрах списков.",
            preferredStyle: .alert
        )
        alert.addTextField { $0.placeholder = "Название" }
        alert.addAction(UIAlertAction(title: "Создать", style: .default) { [weak self] _ in
            let text = alert.textFields?.first?.text ?? ""
            self?.output?.didSubmitNewCategory(name: text)
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func addTagTapped() {
        let tag = (tagInputField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty, !tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) else { return }
        tags.append(tag)
        tagInputField.text = ""
        renderTags()
    }

    private func renderTags() {
        tagsStack.arrangedSubviews.forEach { v in
            tagsStack.removeArrangedSubview(v)
            v.removeFromSuperview()
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
                self?.tags.removeAll(where: { $0 == tag })
                self?.renderTags()
            }, for: .touchUpInside)
            row.addArrangedSubview(label)
            row.addArrangedSubview(removeButton)
            tagsStack.addArrangedSubview(row)
        }
    }
}

// MARK: - SetEditorViewController Extension
extension SetEditorViewController: SetEditorViewInput {
    func configure(title: String, saveTitle: String, draft: SetEditorDraft, categoryPickTitles: [String]) {
        self.title = title
        navigationItem.rightBarButtonItem?.title = saveTitle
        titleField.text = draft.title
        descriptionView.text = draft.description
        tags = draft.tags
        publicSwitch.isOn = !draft.isPrivate
        let titles = categoryPickTitles.isEmpty ? ["Без категории"] : categoryPickTitles
        if titles.contains(draft.category) {
            selectedCategory = draft.category
        } else {
            selectedCategory = titles.first ?? "Без категории"
        }
        buildCategoryChips(titles: titles)
        renderTags()
    }

    func refreshCategoryChips(titles: [String], selectedCategory: String) {
        self.selectedCategory = selectedCategory
        buildCategoryChips(titles: titles)
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
