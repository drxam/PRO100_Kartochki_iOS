//
//  CardsListViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol CardsListViewInput: AnyObject {
    func showInDevelopmentAlert()
    func reloadData()
    func showEmptyState(_ show: Bool)
}

protocol CardsListViewOutput: AnyObject {
    func viewDidLoad()
    func didTapAdd()
    func didSelectCard(_ card: CardModel)
    func didSelectCategory(_ category: String)
    func numberOfCards() -> Int
    func card(at index: Int) -> CardModel
}

final class CardsListViewController: UIViewController {
    var output: CardsListViewOutput?

    private let searchBar = UISearchBar()
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private var categoryButtons: [String: UIButton] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Мои карточки"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTapped))

        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        categoryScroll.showsHorizontalScrollIndicator = false
        categoryScroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryScroll)
        categoryStack.axis = .horizontal
        categoryStack.spacing = 8
        categoryStack.distribution = .fill
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.addSubview(categoryStack)
        for category in MockData.categories {
            let btn = UIButton(type: .system)
            btn.setTitle(category, for: .normal)
            btn.layer.cornerRadius = 16
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            btn.setTitleColor(.label, for: .normal)
            btn.backgroundColor = .secondarySystemFill
            categoryStack.addArrangedSubview(btn)
            categoryButtons[category] = btn
        }
        if let first = MockData.categories.first {
            categoryButtons[first]?.backgroundColor = AppConstants.accentColor
            categoryButtons[first]?.setTitleColor(.white, for: .normal)
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CardListCell.self, forCellReuseIdentifier: CardListCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        emptyLabel.text = "Пока нет данных"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            categoryScroll.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            categoryScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryScroll.heightAnchor.constraint(equalToConstant: 44),
            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor, constant: 16),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -16),
            categoryStack.topAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.topAnchor),
            categoryStack.bottomAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.bottomAnchor),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),
            tableView.topAnchor.constraint(equalTo: categoryScroll.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    @objc private func addTapped() { output?.didTapAdd() }
    @objc private func categoryTapped(_ sender: UIButton) {
        for (_, b) in categoryButtons {
            b.backgroundColor = .secondarySystemFill
            b.setTitleColor(.label, for: .normal)
        }
        sender.backgroundColor = AppConstants.accentColor
        sender.setTitleColor(.white, for: .normal)
        output?.didSelectCategory(sender.title(for: .normal) ?? "")
    }
}

extension CardsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output?.numberOfCards() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardListCell.id, for: indexPath) as! CardListCell
        guard let card = output?.card(at: indexPath.row) else { return cell }
        cell.configure(question: card.question, answer: card.answer, category: card.category, tags: card.tags, setTitle: card.setTitle)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let card = output?.card(at: indexPath.row) else { return }
        output?.didSelectCard(card)
    }
}

extension CardsListViewController: CardsListViewInput {
    func showInDevelopmentAlert() {
        let alert = UIAlertController(title: nil, message: "Функция в разработке", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func reloadData() { tableView.reloadData() }
    func showEmptyState(_ show: Bool) { emptyLabel.isHidden = !show }
}

private final class CardListCell: UITableViewCell {
    static let id = "CardListCell"
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    private let metaLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        questionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        questionLabel.numberOfLines = 1
        answerLabel.font = .systemFont(ofSize: 14)
        answerLabel.textColor = .secondaryLabel
        answerLabel.numberOfLines = 1
        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .tertiaryLabel
        for v in [questionLabel, answerLabel, metaLabel] {
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
            metaLabel.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 4),
            metaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metaLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(question: String, answer: String, category: String, tags: [String], setTitle: String) {
        questionLabel.text = question
        answerLabel.text = answer
        metaLabel.text = "\(category)" + (tags.isEmpty ? "" : " · \(tags.joined(separator: ", "))") + " · \(setTitle)"
    }
}
