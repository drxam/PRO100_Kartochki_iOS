//
//  SetsListViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol SetsListViewInput: AnyObject {
    func showInDevelopmentAlert()
    func showDeleteConfirmAlert(setTitle: String, onConfirm: @escaping () -> Void)
    func reloadData()
    func showEmptyState(_ show: Bool)
}

protocol SetsListViewOutput: AnyObject {
    func viewDidLoad()
    func didTapAdd()
    func didSelectSet(_ set: CardSetModel)
    func didSelectCategory(_ category: String)
    func numberOfSets() -> Int
    func set(at index: Int) -> CardSetModel
}

final class SetsListViewController: UIViewController {
    var output: SetsListViewOutput?

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
        title = "Мои наборы"
        navigationController?.navigationBar.prefersLargeTitles = false

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
        tableView.register(SetCell.self, forCellReuseIdentifier: SetCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorInset = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        emptyLabel.text = "Пока нет данных"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.font = .systemFont(ofSize: 17)
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

    @objc private func addTapped() {
        output?.didTapAdd()
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
}

extension SetsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output?.numberOfSets() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SetCell.id, for: indexPath) as! SetCell
        guard let set = output?.set(at: indexPath.row) else { return cell }
        cell.configure(title: set.title, description: set.description, cardCount: set.cardCount, category: set.category, isPrivate: set.isPrivate)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let set = output?.set(at: indexPath.row) else { return }
        output?.didSelectSet(set)
    }
}

extension SetsListViewController: SetsListViewInput {
    func showInDevelopmentAlert() {
        let alert = UIAlertController(title: nil, message: "Функция в разработке", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showDeleteConfirmAlert(setTitle: String, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: "Удалить набор?", message: "«\(setTitle)» будет удалён.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in onConfirm() })
        present(alert, animated: true)
    }

    func reloadData() {
        tableView.reloadData()
    }

    func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
    }
}

private final class SetCell: UITableViewCell {
    static let id = "SetCell"
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let metaLabel = UILabel()
    private let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 1
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 2
        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = .tertiaryLabel
        lockIcon.tintColor = .secondaryLabel
        lockIcon.contentMode = .scaleAspectFit
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        for v in [titleLabel, descLabel, metaLabel] as [UIView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(v)
        }
        contentView.addSubview(lockIcon)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: lockIcon.leadingAnchor, constant: -8),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            metaLabel.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 4),
            metaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            metaLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            lockIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            lockIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            lockIcon.widthAnchor.constraint(equalToConstant: 16),
            lockIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, description: String, cardCount: Int, category: String, isPrivate: Bool) {
        titleLabel.text = title
        descLabel.text = description
        metaLabel.text = "\(cardCount) карточек · \(category)"
        lockIcon.isHidden = !isPrivate
    }
}
