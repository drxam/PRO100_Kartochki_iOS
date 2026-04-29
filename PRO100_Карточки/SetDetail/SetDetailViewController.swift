//
//  SetDetailViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - SetDetailViewInput
protocol SetDetailViewInput: AnyObject {
    func showInDevelopmentAlert()
    func showDeleteConfirmAlert(onConfirm: @escaping () -> Void)
    func reloadCards()
    func showEmptyState(_ show: Bool)
    func configureInfo(description: String, category: String, tags: String, isPrivate: Bool, cardsCount: Int, progressText: String?)
    func showErrorBanner(_ message: String)
    func setFavoriteState(_ isFavorite: Bool)
}

// MARK: - SetDetailViewOutput
protocol SetDetailViewOutput: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didTapEdit()
    func didTapDelete()
    func didTapStartLearning()
    func didTapAddCard()
    func didTapCopyPublic()
    func didTapToggleFavorite()
    func didTapCard(at index: Int)
    func numberOfCards() -> Int
    func card(at index: Int) -> CardModel
    func getSet() -> CardSetModel
    func isPublicCatalogMode() -> Bool
}

// MARK: - SetDetailViewController
final class SetDetailViewController: UIViewController {
    var output: SetDetailViewOutput?
    var isEditable = true

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let heroCard = UIView()
    private let heroGradient = CAGradientLayer()
    private let heroTitleLabel = UILabel()
    private let descLabel = UILabel()
    private let badgesGridStack = UIStackView()
    private let badgesTopRow = UIStackView()
    private let badgesBottomRow = UIStackView()
    private let categoryBadge = BadgeLabel()
    private let tagsBadge = BadgeLabel()
    private let privacyBadge = BadgeLabel()
    private let cardsCountBadge = BadgeLabel()
    private let progressLabel = UILabel()

    private let learnButton = UIButton(type: .system)
    private let cardsTitleLabel = UILabel()
    private let tableContainer = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addCardButton = UIButton(type: .system)
    private let emptyLabel = UILabel()
    private lazy var favoriteBarButton = UIBarButtonItem(
        image: UIImage(systemName: "heart"),
        style: .plain,
        target: self,
        action: #selector(favoriteTapped)
    )
    private lazy var copyBarButton = UIBarButtonItem(
        image: UIImage(systemName: "square.on.square"),
        style: .plain,
        target: self,
        action: #selector(copyTapped)
    )
    private var tableHeightConstraint: NSLayoutConstraint?
    private let maxTableHeight: CGFloat = 460

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output?.viewWillAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradient.frame = CGRect(
            x: 0,
            y: 0,
            width: heroCard.bounds.width,
            height: heroCard.bounds.height * 1.35
        )
    }

    private func setupUI() {
        view.backgroundColor = DS.bgTop
        applyDarkNavBar()
        guard let set = output?.getSet() else { return }
        title = set.title
        if isEditable {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editTapped)),
                UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteTapped))
            ]
        } else if output?.isPublicCatalogMode() == true {
            navigationItem.rightBarButtonItems = [favoriteBarButton, copyBarButton]
        } else {
            navigationItem.rightBarButtonItems = nil
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroCard.layer.cornerRadius = 24
        heroCard.layer.cornerCurve  = .continuous
        heroCard.layer.masksToBounds = true
        heroCard.backgroundColor = DS.glass
        heroCard.layer.borderWidth = 1
        heroCard.layer.borderColor = DS.glassBdr.cgColor
        contentView.addSubview(heroCard)

        heroGradient.colors = [
            DS.royal.withAlphaComponent(0.30).cgColor,
            DS.crimson.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor,
        ]
        heroGradient.locations = [0.0, 0.55, 1.0]
        heroGradient.startPoint = CGPoint(x: 0, y: 0)
        heroGradient.endPoint = CGPoint(x: 1, y: 1)
        heroCard.layer.insertSublayer(heroGradient, at: 0)

        heroTitleLabel.font = .app(26, .black)
        heroTitleLabel.textColor = .white
        heroTitleLabel.numberOfLines = 2
        heroTitleLabel.text = set.title
        heroTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(heroTitleLabel)

        descLabel.font = .app(15, .medium)
        descLabel.textColor = DS.textDim
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(descLabel)

        badgesGridStack.axis = .vertical
        badgesGridStack.spacing = 8
        badgesGridStack.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(badgesGridStack)

        badgesTopRow.axis = .horizontal
        badgesTopRow.spacing = 8
        badgesTopRow.distribution = .fillEqually
        badgesBottomRow.axis = .horizontal
        badgesBottomRow.spacing = 8
        badgesBottomRow.distribution = .fillEqually
        badgesTopRow.translatesAutoresizingMaskIntoConstraints = false
        badgesBottomRow.translatesAutoresizingMaskIntoConstraints = false
        badgesGridStack.addArrangedSubview(badgesTopRow)
        badgesGridStack.addArrangedSubview(badgesBottomRow)
        badgesTopRow.addArrangedSubview(categoryBadge)
        badgesTopRow.addArrangedSubview(tagsBadge)
        badgesBottomRow.addArrangedSubview(privacyBadge)
        badgesBottomRow.addArrangedSubview(cardsCountBadge)

        progressLabel.font = .app(13, .semibold)
        progressLabel.textColor = DS.textMuted
        progressLabel.numberOfLines = 0
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(progressLabel)

        learnButton.setTitle("▶  Начать обучение", for: .normal)
        learnButton.backgroundColor = DS.royal
        learnButton.setTitleColor(.white, for: .normal)
        learnButton.layer.cornerRadius = 22
        learnButton.layer.cornerCurve  = .continuous
        learnButton.layer.shadowColor  = DS.royal.cgColor
        learnButton.layer.shadowOpacity = 0.5
        learnButton.layer.shadowOffset  = CGSize(width: 0, height: 8)
        learnButton.layer.shadowRadius  = 16
        learnButton.titleLabel?.font = .app(17, .bold)
        learnButton.addTarget(self, action: #selector(learnTapped), for: .touchUpInside)
        learnButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(learnButton)

        cardsTitleLabel.text = "Карточки"
        cardsTitleLabel.font = .app(22, .black)
        cardsTitleLabel.textColor = .white
        cardsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardsTitleLabel)

        tableContainer.backgroundColor = DS.glass
        tableContainer.layer.cornerRadius = 20
        tableContainer.layer.cornerCurve  = .continuous
        tableContainer.layer.borderWidth   = 1
        tableContainer.layer.borderColor   = DS.glassBdr.cgColor
        tableContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableContainer)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.register(CardPreviewCell.self, forCellReuseIdentifier: CardPreviewCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableContainer.addSubview(tableView)

        addCardButton.setTitle("Добавить карточку", for: .normal)
        addCardButton.addTarget(self, action: #selector(addCardTapped), for: .touchUpInside)
        addCardButton.translatesAutoresizingMaskIntoConstraints = false
        addCardButton.isHidden = !isEditable
        contentView.addSubview(addCardButton)

        emptyLabel.text = "Пока нет данных"
        emptyLabel.textColor = DS.textDim
        emptyLabel.font = .app(15, .semibold)
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        tableContainer.addSubview(emptyLabel)

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

            heroCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            heroCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            heroCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            heroTitleLabel.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 18),
            heroTitleLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 16),
            heroTitleLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: heroTitleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -16),

            badgesGridStack.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 14),
            badgesGridStack.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 16),
            badgesGridStack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -16),

            categoryBadge.heightAnchor.constraint(equalToConstant: 30),
            tagsBadge.heightAnchor.constraint(equalToConstant: 30),
            privacyBadge.heightAnchor.constraint(equalToConstant: 30),
            cardsCountBadge.heightAnchor.constraint(equalToConstant: 30),

            progressLabel.topAnchor.constraint(equalTo: badgesGridStack.bottomAnchor, constant: 10),
            progressLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 16),
            progressLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -16),
            progressLabel.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -16),

            learnButton.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 16),
            learnButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            learnButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            learnButton.heightAnchor.constraint(equalToConstant: 54),

            cardsTitleLabel.topAnchor.constraint(equalTo: learnButton.bottomAnchor, constant: 24),
            cardsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            tableContainer.topAnchor.constraint(equalTo: cardsTitleLabel.bottomAnchor, constant: 10),
            tableContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            tableContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor),

            addCardButton.topAnchor.constraint(equalTo: tableContainer.bottomAnchor, constant: 16),
            addCardButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addCardButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            emptyLabel.centerXAnchor.constraint(equalTo: tableContainer.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableContainer.centerYAnchor)
        ])
        tableHeightConstraint = tableContainer.heightAnchor.constraint(equalToConstant: 300)
        tableHeightConstraint?.isActive = true

    }

    @objc private func editTapped() { output?.didTapEdit() }
    @objc private func deleteTapped() { output?.didTapDelete() }
    @objc private func learnTapped() { output?.didTapStartLearning() }
    @objc private func addCardTapped() { output?.didTapAddCard() }
    @objc private func copyTapped() { output?.didTapCopyPublic() }
    @objc private func favoriteTapped() { output?.didTapToggleFavorite() }
}

// MARK: - SetDetailViewController Extension
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

// MARK: - SetDetailViewController Extension
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
        let rows = output?.numberOfCards() ?? 0
        let contentHeight = max(132, CGFloat(rows) * 84)
        tableHeightConstraint?.constant = min(maxTableHeight, contentHeight)
        tableView.isScrollEnabled = contentHeight > maxTableHeight
    }

    func showEmptyState(_ show: Bool) {
        emptyLabel.isHidden = !show
    }

    func configureInfo(description: String, category: String, tags: String, isPrivate: Bool, cardsCount: Int, progressText: String?) {
        descLabel.text = description.isEmpty ? "Без описания" : description
        categoryBadge.text = "Категория: \(category)"
        tagsBadge.text = tags.isEmpty ? "Тегов нет" : "Теги: \(tags)"
        privacyBadge.text = isPrivate ? "Приватный" : "Публичный"
        cardsCountBadge.text = "Карточек: \(cardsCount)"
        progressLabel.text = progressText
        progressLabel.isHidden = (progressText?.isEmpty ?? true)
        learnButton.isEnabled = cardsCount > 0
        learnButton.alpha = cardsCount > 0 ? 1.0 : 0.5
    }

    func showErrorBanner(_ message: String) {
        showTopBanner(message)
    }

    func setFavoriteState(_ isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteBarButton.image = UIImage(systemName: imageName)
        favoriteBarButton.tintColor = isFavorite ? .systemPink : nil
    }
}

private final class CardPreviewCell: UITableViewCell {
    static let id = "CardPreviewCell"
    private let cardBackground = UIView()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        cardBackground.backgroundColor  = DS.glass
        cardBackground.layer.cornerRadius = 16
        cardBackground.layer.cornerCurve  = .continuous
        cardBackground.layer.borderWidth  = 1
        cardBackground.layer.borderColor  = DS.glassBdr.cgColor
        contentView.addSubview(cardBackground)
        questionLabel.font = .app(16, .bold)
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 2
        answerLabel.font = .app(14, .regular)
        answerLabel.textColor = DS.textDim
        answerLabel.numberOfLines = 2
        for v in [questionLabel, answerLabel] {
            v.translatesAutoresizingMaskIntoConstraints = false
            cardBackground.addSubview(v)
        }
        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            cardBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            cardBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            cardBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7),
            questionLabel.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 13),
            questionLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 14),
            questionLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -14),
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 6),
            answerLabel.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 14),
            answerLabel.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -14),
            answerLabel.bottomAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: -13)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(question: String, answer: String) {
        questionLabel.text = question
        answerLabel.text = answer
    }
}

private final class BadgeLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = .app(12, .bold)
        textColor = DS.textDim
        backgroundColor = DS.field
        layer.cornerRadius = 12
        layer.cornerCurve  = .continuous
        layer.masksToBounds = true
        layer.borderWidth  = 1
        layer.borderColor  = DS.glassBdr.cgColor
        textAlignment = .left
        numberOfLines = 1
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var text: String? {
        didSet {
            let raw = text ?? ""
            super.text = "  \(raw)  "
        }
    }
}
