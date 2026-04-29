//
//  PublicListViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - PublicListViewInput
protocol PublicListViewInput: AnyObject {
    func showInDevelopmentAlert()
    func reloadData()
    func showEmptyState(_ show: Bool)
    func showSortOptions(selected: String)
    func setSortTitle(_ title: String)
    func setFavoritesTitle(_ title: String)
    func setCategoryChips(titles: [String], selected: String)
    func showErrorToast(_ message: String)
}

// MARK: - PublicListViewOutput
protocol PublicListViewOutput: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didSelectCategory(_ category: String)
    func didSelectSort()
    func didSelectSortOption(_ option: String)
    func didTapFavoritesToggle()
    func didSearch(text: String)
    func didSelectSet(_ set: PublicSetModel)
    func didPullToRefresh()
    func didRequestNextPage()
    func numberOfSets() -> Int
    func publicSet(at index: Int) -> PublicSetModel
}

// MARK: - PublicListViewController
final class PublicListViewController: UIViewController {
    var output: PublicListViewOutput?

    private let topContainer = UIView()
    private let searchBar = UISearchBar()
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let controlsRow = UIStackView()
    private let sortButton = UIButton(type: .system)
    private let favoritesButton = UIButton(type: .system)
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
        title = "Публичные наборы"
        navigationController?.navigationBar.prefersLargeTitles = true

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

        controlsRow.axis = .horizontal
        controlsRow.spacing = 10
        controlsRow.distribution = .fillEqually
        controlsRow.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(controlsRow)

        sortButton.configuration = Self.controlButtonConfiguration(title: "Сортировка", image: "arrow.up.arrow.down")
        sortButton.addTarget(self, action: #selector(sortTapped), for: .touchUpInside)

        favoritesButton.configuration = Self.controlButtonConfiguration(title: "Избранные: выкл", image: "star")
        favoritesButton.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)

        controlsRow.addArrangedSubview(favoritesButton)
        controlsRow.addArrangedSubview(sortButton)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PublicSetCell.self, forCellReuseIdentifier: PublicSetCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 122
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

            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor, constant: 16),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -16),
            categoryStack.topAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.topAnchor),
            categoryStack.bottomAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.bottomAnchor),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),

            controlsRow.topAnchor.constraint(equalTo: categoryScroll.bottomAnchor, constant: 8),
            controlsRow.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 14),
            controlsRow.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -14),
            controlsRow.heightAnchor.constraint(equalToConstant: 36),
            controlsRow.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -4),

            tableView.topAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
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

    @objc private func sortTapped() {
        output?.didSelectSort()
    }

    @objc private func favoritesTapped() {
        output?.didTapFavoritesToggle()
    }

    @objc private func refreshPulled() {
        output?.didPullToRefresh()
    }

    private static func controlButtonConfiguration(title: String, image: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.app(13, .bold)
            return outgoing
        }
        config.image = UIImage(systemName: image)
        config.imagePadding = 6
        config.baseForegroundColor = DS.textDim
        config.baseBackgroundColor = DS.field
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        return config
    }
}

// MARK: - PublicListViewController Extension
extension PublicListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output?.numberOfSets() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PublicSetCell.id, for: indexPath) as! PublicSetCell
        guard let set = output?.publicSet(at: indexPath.row) else { return cell }
        cell.configure(
            authorName: set.authorName,
            avatarURLString: set.authorAvatarURL,
            title: set.title,
            cardCount: set.cardCount,
            category: set.category
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let set = output?.publicSet(at: indexPath.row) else { return }
        output?.didSelectSet(set)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = scrollView.contentSize.height - scrollView.bounds.height - 120
        if scrollView.contentOffset.y > threshold {
            output?.didRequestNextPage()
        }
    }
}

// MARK: - PublicListViewController Extension
extension PublicListViewController: PublicListViewInput {
    func showInDevelopmentAlert() {
        let alert = UIAlertController(title: nil, message: "Функция в разработке", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func reloadData() {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
    }

    func showSortOptions(selected: String) {
        let alert = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        ["Популярность", "Дата", "Количество карточек"].forEach { option in
            let title = option == selected ? "✓ \(option)" : option
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { [weak self] _ in
                self?.output?.didSelectSortOption(option)
            }))
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        if let pop = alert.popoverPresentationController {
            pop.sourceView = sortButton
            pop.sourceRect = sortButton.bounds
        }
        present(alert, animated: true)
    }

    func setSortTitle(_ title: String) {
        var config = sortButton.configuration ?? Self.controlButtonConfiguration(title: "", image: "arrow.up.arrow.down")
        config.title = "Сорт: \(title)"
        sortButton.configuration = config
    }

    func setFavoritesTitle(_ title: String) {
        let isOn = title.lowercased().contains("вкл")
        var config = favoritesButton.configuration ?? Self.controlButtonConfiguration(title: "", image: "star")
        config.title = title
        config.image = UIImage(systemName: isOn ? "star.fill" : "star")
        config.baseForegroundColor = isOn ? DS.royal : DS.textDim
        config.baseBackgroundColor = isOn ? DS.royal.withAlphaComponent(0.18) : DS.field
        favoritesButton.configuration = config
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

// MARK: - PublicListViewController Extension
extension PublicListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        output?.didSearch(text: searchText)
    }
}

private final class PublicSetCell: UITableViewCell {
    static let id = "PublicSetCell"

    private let cardView = UIView()
    private let avatarImageView = UIImageView()
    private let initialsLabel = UILabel()
    private let authorLabel = UILabel()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private var avatarTask: URLSessionDataTask?

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

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = DS.royal.withAlphaComponent(0.3)
        avatarImageView.contentMode = .scaleAspectFill

        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.font = .app(15, .bold)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center

        authorLabel.font = .app(13, .semibold)
        authorLabel.textColor = DS.textDim
        titleLabel.font = .app(17, .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        metaLabel.font = .app(12, .semibold)
        metaLabel.textColor = DS.textMuted
        metaLabel.numberOfLines = 2

        cardView.addSubview(avatarImageView)
        avatarImageView.addSubview(initialsLabel)
        for v in [authorLabel, titleLabel, metaLabel] {
            v.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(v)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),

            avatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 13),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            initialsLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),

            authorLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            authorLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 13),
            authorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 3),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            metaLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            metaLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            metaLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -13)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarTask?.cancel()
        avatarTask = nil
        avatarImageView.image = nil
        initialsLabel.text = nil
    }

    func configure(authorName: String, avatarURLString: String?, title: String, cardCount: Int, category: String) {
        authorLabel.text = authorName
        titleLabel.text = title
        metaLabel.text = "\(cardCount) карточек · \(category)"

        avatarTask?.cancel()
        avatarTask = nil
        avatarImageView.image = nil

        let initial = authorName.trimmingCharacters(in: .whitespacesAndNewlines).first.map { String($0).uppercased() } ?? "?"
        initialsLabel.text = initial
        initialsLabel.isHidden = false

        guard let url = Self.resolvedAvatarURL(avatarURLString) else { return }
        avatarTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.avatarTask = nil
                if let data, let img = UIImage(data: data) {
                    self.avatarImageView.image = img
                    self.initialsLabel.isHidden = true
                }
            }
        }
        avatarTask?.resume()
    }

    private static func resolvedAvatarURL(_ raw: String?) -> URL? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        if let u = URL(string: raw), u.scheme != nil { return u }
        if raw.hasPrefix("/") {
            return URL(string: raw, relativeTo: APIConfig.siteOrigin)?.absoluteURL
        }
        return URL(string: raw, relativeTo: APIConfig.siteOrigin)?.absoluteURL
    }
}
