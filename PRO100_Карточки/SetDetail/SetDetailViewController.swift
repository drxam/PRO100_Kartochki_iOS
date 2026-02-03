//
//  SetDetailViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol SetDetailViewInput: AnyObject {
    func showInDevelopmentAlert()
    func showDeleteConfirmAlert(onConfirm: @escaping () -> Void)
    func reloadCards()
    func showEmptyState(_ show: Bool)
    func configureInfo(description: String, category: String, tags: String, isPrivate: Bool)
}

protocol SetDetailViewOutput: AnyObject {
    func viewDidLoad()
    func didTapEdit()
    func didTapDelete()
    func didTapStartLearning()
    func didTapAddCard()
    func didTapCard(at index: Int)
    func numberOfCards() -> Int
    func card(at index: Int) -> CardModel
    func getSet() -> CardSetModel
}

final class SetDetailViewController: UIViewController {
    var output: SetDetailViewOutput?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let descLabel = UILabel()
    private let categoryLabel = UILabel()
    private let tagsLabel = UILabel()
    private let privateLabel = UILabel()
    private let learnButton = UIButton(type: .system)
    private let cardsTitleLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addCardButton = UIButton(type: .system)
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        guard let set = output?.getSet() else { return }
        title = set.title
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editTapped)),
            UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteTapped))
        ]

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        descLabel.font = .systemFont(ofSize: 15)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descLabel)

        categoryLabel.font = .systemFont(ofSize: 13)
        categoryLabel.textColor = .tertiaryLabel
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)

        tagsLabel.font = .systemFont(ofSize: 13)
        tagsLabel.textColor = .tertiaryLabel
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagsLabel)

        privateLabel.font = .systemFont(ofSize: 13)
        privateLabel.textColor = .tertiaryLabel
        privateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(privateLabel)

        learnButton.setTitle("Начать обучение", for: .normal)
        learnButton.backgroundColor = AppConstants.accentColor
        learnButton.setTitleColor(.white, for: .normal)
        learnButton.layer.cornerRadius = 12
        learnButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        learnButton.addTarget(self, action: #selector(learnTapped), for: .touchUpInside)
        learnButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(learnButton)

        cardsTitleLabel.text = "Карточки набора"
        cardsTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        cardsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardsTitleLabel)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(CardPreviewCell.self, forCellReuseIdentifier: CardPreviewCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)

        addCardButton.setTitle("Добавить карточку", for: .normal)
        addCardButton.addTarget(self, action: #selector(addCardTapped), for: .touchUpInside)
        addCardButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addCardButton)

        emptyLabel.text = "Пока нет данных"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emptyLabel)

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

            descLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            categoryLabel.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            tagsLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            tagsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            privateLabel.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 4),
            privateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            learnButton.topAnchor.constraint(equalTo: privateLabel.bottomAnchor, constant: 20),
            learnButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            learnButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            learnButton.heightAnchor.constraint(equalToConstant: 50),

            cardsTitleLabel.topAnchor.constraint(equalTo: learnButton.bottomAnchor, constant: 24),
            cardsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            tableView.topAnchor.constraint(equalTo: cardsTitleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 300),

            addCardButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            addCardButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addCardButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    @objc private func editTapped() { output?.didTapEdit() }
    @objc private func deleteTapped() { output?.didTapDelete() }
    @objc private func learnTapped() { output?.didTapStartLearning() }
    @objc private func addCardTapped() { output?.didTapAddCard() }
}

extension SetDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output?.numberOfCards() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardPreviewCell.id, for: indexPath) as! CardPreviewCell
        guard let card = output?.card(at: indexPath.row) else { return cell }
        cell.configure(question: card.question, answer: card.answer)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output?.didTapCard(at: indexPath.row)
    }
}

extension SetDetailViewController: SetDetailViewInput {
    func showInDevelopmentAlert() {
        let alert = UIAlertController(title: nil, message: "Функция в разработке", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showDeleteConfirmAlert(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: "Удалить набор?", message: "Набор будет удалён безвозвратно.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in onConfirm() })
        present(alert, animated: true)
    }

    func reloadCards() {
        tableView.reloadData()
    }

    func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
    }

    func configureInfo(description: String, category: String, tags: String, isPrivate: Bool) {
        descLabel.text = description
        categoryLabel.text = "Категория: \(category)"
        tagsLabel.text = tags.isEmpty ? "" : "Теги: \(tags)"
        privateLabel.text = isPrivate ? "Приватный набор" : "Публичный набор"
    }
}

private final class CardPreviewCell: UITableViewCell {
    static let id = "CardPreviewCell"
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        questionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        questionLabel.numberOfLines = 1
        answerLabel.font = .systemFont(ofSize: 13)
        answerLabel.textColor = .secondaryLabel
        answerLabel.numberOfLines = 1
        for v in [questionLabel, answerLabel] {
            v.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(v)
        }
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 4),
            answerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            answerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            answerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(question: String, answer: String) {
        questionLabel.text = question
        answerLabel.text = answer
    }
}
