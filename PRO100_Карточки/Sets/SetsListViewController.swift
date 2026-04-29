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
    func setCategoryChips(titles: [String], selected: String)
    func showErrorToast(_ message: String)
}

protocol SetsListViewOutput: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didTapAdd()
    func didSelectSet(_ set: CardSetModel)
    func didSelectCategory(_ category: String)
    func didSearch(text: String)
    func didPullToRefresh()
    func didRequestNextPage()
    func numberOfSets() -> Int
    func set(at index: Int) -> CardSetModel
}

final class SetsListViewController: UIViewController {
    var output: SetsListViewOutput?

    private let topContainer = UIView()
    private let searchBar = UISearchBar()
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let refreshControl = UIRefreshControl()
    private var categoryButtons: [String: UIButton] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output?.viewWillAppear()
    }

    private func setupUI() {
        view.backgroundColor = DS.bgTop
        applyDarkNavBar()
        title = "Мои наборы"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = DS.royal

        topContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topContainer)

        searchBar.placeholder = "Поиск наборов"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.barTintColor = .clear
        searchBar.searchTextField.backgroundColor = DS.field
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.tintColor = DS.royal
        searchBar.searchTextField.leftView?.tintColor = DS.textDim
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск наборов",
            attributes: [.foregroundColor: DS.textDim, .font: UIFont.app(15, .regular)]
        )
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(searchBar)

        categoryScroll.showsHorizontalScrollIndicator = false
        categoryScroll.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(categoryScroll)

        categoryStack.axis = .horizontal
        categoryStack.spacing = 10
        categoryStack.distribution = .fill
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.addSubview(categoryStack)

        setCategoryChips(titles: ["Все"], selected: "Все")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SetCell.self, forCellReuseIdentifier: SetCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 118
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 18, right: 0)
        refreshControl.tintColor = DS.royal
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        emptyLabel.text = "Пока нет наборов"
        emptyLabel.textColor = DS.textDim
        emptyLabel.font = .app(17, .semibold)
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            searchBar.topAnchor.constraint(equalTo: topContainer.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            categoryScroll.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            categoryScroll.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            categoryScroll.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            categoryScroll.heightAnchor.constraint(equalToConstant: 44),
            categoryScroll.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -4),

            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor, constant: 16),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -16),
            categoryStack.topAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.topAnchor),
            categoryStack.bottomAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.bottomAnchor),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),

            tableView.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: 4),
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
            b.backgroundColor = DS.field
            b.setTitleColor(DS.textDim, for: .normal)
            b.layer.borderColor = DS.glassBdr.cgColor
        }
        sender.backgroundColor = DS.royal
        sender.setTitleColor(.white, for: .normal)
        sender.layer.borderColor = UIColor.clear.cgColor
        output?.didSelectCategory(sender.title(for: .normal) ?? "")
    }

    @objc private func refreshPulled() {
        output?.didPullToRefresh()
    }
}

extension SetsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output?.numberOfSets() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SetCell.id, for: indexPath) as! SetCell
        guard let set = output?.set(at: indexPath.row) else { return cell }
        cell.configure(
            title: set.title,
            description: set.description,
            cardCount: set.cardCount,
            category: set.category,
            isPrivate: set.isPrivate
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let set = output?.set(at: indexPath.row) else { return }
        output?.didSelectSet(set)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = scrollView.contentSize.height - scrollView.bounds.height - 120
        if scrollView.contentOffset.y > threshold {
            output?.didRequestNextPage()
        }
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
        refreshControl.endRefreshing()
    }

    func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
    }

    func setCategoryChips(titles: [String], selected: String) {
        for v in categoryStack.arrangedSubviews {
            categoryStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        categoryButtons.removeAll()
        for name in titles {
            let btn = UIButton(type: .system)
            btn.setTitle(name, for: .normal)
            btn.titleLabel?.font = .app(13, .bold)
            btn.layer.cornerRadius = 16
            btn.layer.cornerCurve  = .continuous
            btn.layer.borderWidth  = 1
            btn.layer.borderColor  = DS.glassBdr.cgColor
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            btn.setTitleColor(DS.textDim, for: .normal)
            btn.backgroundColor = DS.field
            categoryStack.addArrangedSubview(btn)
            categoryButtons[name] = btn
        }
        if let sel = categoryButtons[selected] {
            sel.backgroundColor = DS.royal
            sel.setTitleColor(.white, for: .normal)
            sel.layer.borderColor = UIColor.clear.cgColor
        } else if let all = categoryButtons["Все"] {
            all.backgroundColor = DS.royal
            all.setTitleColor(.white, for: .normal)
            all.layer.borderColor = UIColor.clear.cgColor
        }
    }

    func showErrorToast(_ message: String) {
        showToast(message)
    }
}

extension SetsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        output?.didSearch(text: searchText)
    }
}

private final class SetCell: UITableViewCell {
    static let id = "SetCell"
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let metaLabel = UILabel()
    private let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = DS.glass
        cardView.layer.cornerRadius = 20
        cardView.layer.cornerCurve  = .continuous
        cardView.layer.borderWidth  = 1
        cardView.layer.borderColor  = DS.glassBdr.cgColor
        cardView.layer.shadowColor  = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.30
        cardView.layer.shadowRadius  = 14
        cardView.layer.shadowOffset  = CGSize(width: 0, height: 6)
        cardView.layer.masksToBounds = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        titleLabel.font = .app(17, .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        descLabel.font = .app(14, .regular)
        descLabel.textColor = DS.textDim
        descLabel.numberOfLines = 2
        metaLabel.font = .app(12, .semibold)
        metaLabel.textColor = DS.textMuted
        metaLabel.numberOfLines = 2
        lockIcon.tintColor = DS.textDim
        lockIcon.contentMode = .scaleAspectFit
        lockIcon.translatesAutoresizingMaskIntoConstraints = false

        for v in [titleLabel, descLabel, metaLabel] as [UIView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(v)
        }
        cardView.addSubview(lockIcon)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 13),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: lockIcon.leadingAnchor, constant: -8),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            metaLabel.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 7),
            metaLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            metaLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            metaLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -13),

            lockIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            lockIcon.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            lockIcon.widthAnchor.constraint(equalToConstant: 16),
            lockIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, description: String, cardCount: Int, category: String, isPrivate: Bool) {
        titleLabel.text = title
        descLabel.text = description.isEmpty ? "Без описания" : description
        metaLabel.text = "\(cardCount) карточек · \(category)"
        lockIcon.isHidden = !isPrivate
    }
}
