//
//  CardDetailViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - CardDetailViewController
final class CardDetailViewController: UIViewController {
    private var cards: [CardModel]
    private var selectedIndex: Int
    private let readOnly: Bool

    private var currentCard: CardModel {
        cards[selectedIndex]
    }

    private let questionContainer = UIView()
    private let answerContainer = UIView()
    private let questionLabel = UILabel()
    private let divider = UIView()
    private let answerLabel = UILabel()
    private let metaLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)

    init(cards: [CardModel], selectedIndex: Int, readOnly: Bool = false) {
        self.cards = cards
        self.selectedIndex = max(0, min(selectedIndex, max(cards.count - 1, 0)))
        self.readOnly = readOnly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndex = min(selectedIndex, max(cards.count - 1, 0))
        updateUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Карточка"
        if !readOnly {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editTapped)),
                UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteTapped))
            ]
        }

        questionContainer.backgroundColor = .secondarySystemBackground
        questionContainer.layer.cornerRadius = 12
        questionContainer.translatesAutoresizingMaskIntoConstraints = false

        answerContainer.backgroundColor = .secondarySystemBackground
        answerContainer.layer.cornerRadius = 12
        answerContainer.translatesAutoresizingMaskIntoConstraints = false

        questionLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.translatesAutoresizingMaskIntoConstraints = false

        divider.backgroundColor = .systemGray4
        divider.translatesAutoresizingMaskIntoConstraints = false

        answerLabel.font = .systemFont(ofSize: 18)
        answerLabel.textColor = .secondaryLabel
        answerLabel.numberOfLines = 0
        answerLabel.textAlignment = .center
        answerLabel.translatesAutoresizingMaskIntoConstraints = false

        metaLabel.font = .systemFont(ofSize: 14)
        metaLabel.textColor = .tertiaryLabel
        metaLabel.numberOfLines = 0
        metaLabel.translatesAutoresizingMaskIntoConstraints = false

        prevButton.setTitle("◀", for: .normal)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("▶", for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(questionContainer)
        view.addSubview(divider)
        view.addSubview(answerContainer)
        questionContainer.addSubview(questionLabel)
        answerContainer.addSubview(answerLabel)
        [metaLabel, prevButton, nextButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            questionContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            questionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            questionContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.32),

            questionLabel.leadingAnchor.constraint(equalTo: questionContainer.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: questionContainer.trailingAnchor, constant: -16),
            questionLabel.centerYAnchor.constraint(equalTo: questionContainer.centerYAnchor),

            divider.topAnchor.constraint(equalTo: questionContainer.bottomAnchor, constant: 10),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1),

            answerContainer.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 10),
            answerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            answerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            answerContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.32),

            answerLabel.leadingAnchor.constraint(equalTo: answerContainer.leadingAnchor, constant: 16),
            answerLabel.trailingAnchor.constraint(equalTo: answerContainer.trailingAnchor, constant: -16),
            answerLabel.centerYAnchor.constraint(equalTo: answerContainer.centerYAnchor),

            metaLabel.topAnchor.constraint(equalTo: answerContainer.bottomAnchor, constant: 16),
            metaLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            metaLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            prevButton.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 12),
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            prevButton.widthAnchor.constraint(equalToConstant: 44),
            prevButton.heightAnchor.constraint(equalToConstant: 44),

            nextButton.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 12),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(nextTapped))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(prevTapped))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        updateUI()
    }

    private func updateUI() {
        questionLabel.text = currentCard.question
        answerLabel.text = currentCard.answer
        let tags = currentCard.tags.isEmpty ? "нет" : currentCard.tags.joined(separator: ", ")
        metaLabel.text = "Категория: \(currentCard.category)\nТеги: \(tags)\nНабор: \(currentCard.setTitle)"
        prevButton.isEnabled = selectedIndex > 0
        nextButton.isEnabled = selectedIndex < cards.count - 1
    }

    @objc private func prevTapped() {
        guard selectedIndex > 0 else { return }
        selectedIndex -= 1
        updateUI()
    }

    @objc private func nextTapped() {
        guard selectedIndex < cards.count - 1 else { return }
        selectedIndex += 1
        updateUI()
    }

    @objc private func editTapped() {
        let vc = CardEditorAssembly().makeModule(mode: .edit(currentCard))
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Удалить карточку?", message: "Действие нельзя отменить.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            guard let self, let id = Int(self.currentCard.id) else { return }
            StudyContentService.shared.deleteCard(id: id) { [weak self] result in
                guard let self else { return }
                if case .success = result {
                    self.cards.remove(at: self.selectedIndex)
                    if self.cards.isEmpty {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.selectedIndex = min(self.selectedIndex, self.cards.count - 1)
                        self.updateUI()
                    }
                } else {
                    self.showTopBanner("Не удалось удалить карточку")
                }
            }
        }))
        present(alert, animated: true)
    }
}
