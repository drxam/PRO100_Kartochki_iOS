//
//  CardsListViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol CardsListViewInput: AnyObject {
    func showInDevelopmentAlert()
    func reloadData()
    func showEmptyState(_ show: Bool)
    func presentTagPicker(selectedName: String?, onPick: @escaping (APITag?) -> Void)
    func setCategoryChips(titles: [String], selected: String)
    func showErrorToast(_ message: String)
}

protocol CardsListViewOutput: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didTapAdd()
    func didSelectCard(at index: Int)
    func didSelectCategory(_ category: String)
    func tagFilterPicked(_ tag: APITag?)
    func didSearch(text: String)
    func didPullToRefresh()
    func didRequestNextPage()
    func didTapTagFilter()
    func numberOfCards() -> Int
    func card(at index: Int) -> CardModel
}

final class CardsListViewController: UIViewController {
    var output: CardsListViewOutput?

    private let topContainer = UIView()
    private let searchBar = UISearchBar()
    private let categoryScroll = UIScrollView()
    private let categoryStack = UIStackView()
    private let tagFilterButton = UIButton(type: .system)
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
        title = "Мои карточки"
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

        searchBar.placeholder = "Поиск карточек"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.barTintColor = .clear
        searchBar.searchTextField.backgroundColor = DS.field
        searchBar.searchTextField.textColor = .white
        searchBar.searchTextField.tintColor = DS.royal
        searchBar.searchTextField.leftView?.tintColor = DS.textDim
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск карточек",
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

        var tagConfig = UIButton.Configuration.filled()
        tagConfig.title = "Теги: все"
        tagConfig.baseBackgroundColor = DS.field
        tagConfig.baseForegroundColor = DS.textDim
        tagConfig.cornerStyle = .capsule
        tagConfig.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
        tagFilterButton.configuration = tagConfig
        tagFilterButton.contentHorizontalAlignment = .right
        tagFilterButton.addTarget(self, action: #selector(tagFilterTapped), for: .touchUpInside)
        tagFilterButton.translatesAutoresizingMaskIntoConstraints = false
        topContainer.addSubview(tagFilterButton)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CardListCell.self, forCellReuseIdentifier: CardListCell.id)
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

        emptyLabel.text = "Пока нет карточек"
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
            categoryScroll.trailingAnchor.constraint(equalTo: tagFilterButton.leadingAnchor, constant: -10),
            categoryScroll.heightAnchor.constraint(equalToConstant: 44),

            categoryStack.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor, constant: 16),
            categoryStack.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor, constant: -16),
            categoryStack.topAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.topAnchor),
            categoryStack.bottomAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.bottomAnchor),
            categoryStack.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),

            tagFilterButton.centerYAnchor.constraint(equalTo: categoryScroll.centerYAnchor),
            tagFilterButton.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -16),
            tagFilterButton.heightAnchor.constraint(equalToConstant: 34),
            tagFilterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 104),

            categoryScroll.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor, constant: -4),

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

    @objc private func tagFilterTapped() {
        output?.didTapTagFilter()
    }
}

extension CardsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output?.numberOfCards() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CardListCell.id, for: indexPath) as! CardListCell
        guard let card = output?.card(at: indexPath.row) else { return cell }
        cell.configure(
            question: card.question,
            answer: card.answer,
            category: card.category,
            tags: card.tags,
            setTitle: card.setTitle
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        output?.didSelectCard(at: indexPath.row)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = scrollView.contentSize.height - scrollView.bounds.height - 120
        if scrollView.contentOffset.y > threshold {
            output?.didRequestNextPage()
        }
    }
}

extension CardsListViewController: CardsListViewInput {
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

    func presentTagPicker(selectedName: String?, onPick: @escaping (APITag?) -> Void) {
        let picker = TagPickerViewController()
        picker.selectedName = selectedName
        picker.onPick = { [weak self] tag in
            self?.setTagFilterTitle(tag: tag)
            onPick(tag)
        }
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
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

extension CardsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        output?.didSearch(text: searchText)
    }
}

private extension CardsListViewController {
    func setTagFilterTitle(tag: APITag?) {
        var config = tagFilterButton.configuration ?? UIButton.Configuration.filled()
        config.title = tag.map { "Тег: \($0.name)" } ?? "Теги: все"
        config.baseBackgroundColor = tag != nil ? DS.royal : DS.field
        config.baseForegroundColor = tag != nil ? .white : DS.textDim
        tagFilterButton.configuration = config
    }
}

private final class CardListCell: UITableViewCell {
    static let id = "CardListCell"

    private let cardView = UIView()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    private let metaLabel = UILabel()

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

        questionLabel.font = .app(17, .bold)
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 2
        answerLabel.font = .app(14, .regular)
        answerLabel.textColor = DS.textDim
        answerLabel.numberOfLines = 2
        metaLabel.font = .app(12, .semibold)
        metaLabel.textColor = DS.textMuted
        metaLabel.numberOfLines = 2

        for v in [questionLabel, answerLabel, metaLabel] as [UIView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(v)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),

            questionLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 13),
            questionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            questionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 5),
            answerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            answerLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),

            metaLabel.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 8),
            metaLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            metaLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            metaLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -13)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(question: String, answer: String, category: String, tags: [String], setTitle: String) {
        questionLabel.text = question
        answerLabel.text = answer

        var parts: [String] = []
        if !category.isEmpty { parts.append(category) }
        if !tags.isEmpty { parts.append(tags.joined(separator: ", ")) }
        if !setTitle.isEmpty { parts.append(setTitle) }
        metaLabel.text = parts.joined(separator: " · ")
    }
}
