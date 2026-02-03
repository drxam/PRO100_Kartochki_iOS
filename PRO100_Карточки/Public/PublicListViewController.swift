//
//  PublicListViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol PublicListViewInput: AnyObject {
    func showInDevelopmentAlert()
    func reloadData()
    func showEmptyState(_ show: Bool)
}

protocol PublicListViewOutput: AnyObject {
    func viewDidLoad()
    func didSelectCategory(_ category: String)
    func didSelectSort()
    func didSelectSet()
    func numberOfSets() -> Int
    func publicSet(at index: Int) -> PublicSetModel
}

final class PublicListViewController: UIViewController {
    var output: PublicListViewOutput?

    private let searchBar = UISearchBar()
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let sortButton = UIButton(type: .system)
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
        title = "Публичные наборы"

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

        sortButton.setTitle("Сортировка ▼", for: .normal)
        sortButton.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sortButton)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PublicSetCell.self, forCellReuseIdentifier: PublicSetCell.id)
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
            sortButton.topAnchor.constraint(equalTo: categoryScroll.bottomAnchor, constant: 8),
            sortButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }

    @objc private func categoryTapped(_ sender: UIButton) {
        for (_, b) in categoryButtons {
            b.backgroundColor = .secondarySystemFill
            b.setTitleColor(.label, for: .normal)
        }
        sender.backgroundColor = AppConstants.accentColor
        sender.setTitleColor(.white, for: .normal)
        output?.didSelectCategory(sender.title(for: .normal) ?? "")
    }

    @objc private func sortTapped() {
        output?.didSelectSort()
    }
}

extension PublicListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output?.numberOfSets() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PublicSetCell.id, for: indexPath) as! PublicSetCell
        guard let set = output?.publicSet(at: indexPath.row) else { return cell }
        cell.configure(authorName: set.authorName, title: set.title, cardCount: set.cardCount, category: set.category)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output?.didSelectSet()
    }
}

extension PublicListViewController: PublicListViewInput {
    func showInDevelopmentAlert() {
        let alert = UIAlertController(title: nil, message: "Функция в разработке", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func reloadData() { tableView.reloadData() }
    func showEmptyState(_ show: Bool) { emptyLabel.isHidden = !show }
}

private final class PublicSetCell: UITableViewCell {
    static let id = "PublicSetCell"
    private let avatarView = UIView()
    private let authorLabel = UILabel()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        avatarView.backgroundColor = .tertiarySystemFill
        avatarView.layer.cornerRadius = 20
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = .systemFont(ofSize: 13)
        authorLabel.textColor = .secondaryLabel
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .tertiaryLabel
        contentView.addSubview(avatarView)
        for v in [authorLabel, titleLabel, metaLabel] {
            v.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(v)
        }
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            authorLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            authorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            metaLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            metaLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(authorName: String, title: String, cardCount: Int, category: String) {
        authorLabel.text = authorName
        self.titleLabel.text = title
        metaLabel.text = "\(cardCount) карточек · \(category)"
    }
}
