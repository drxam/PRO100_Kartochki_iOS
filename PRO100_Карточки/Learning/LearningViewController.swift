//
//  LearningViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol LearningViewInput: AnyObject {}

protocol LearningViewOutput: AnyObject {
    func viewDidLoad()
    func didTapClose()
    func didTapShowAnswer()
    func didTapRating(_ rating: LearningRating)
    func currentProgress() -> (current: Int, total: Int)
    func currentCardQuestion() -> String
    func currentCardAnswer() -> String
    func isAnswerShown() -> Bool
}

enum LearningRating {
    case hard    // Не помню - красная
    case medium  // Сложно - жёлтая
    case easy    // Легко - зелёная
}

final class LearningViewController: UIViewController {
    var output: LearningViewOutput?

    private let progressLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let cardContainer = UIView()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    private let showAnswerButton = UIButton(type: .system)
    private let ratingStack = UIStackView()
    private let hardButton = UIButton(type: .system)
    private let mediumButton = UIButton(type: .system)
    private let easyButton = UIButton(type: .system)
    private var isFlipped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
        updateContent()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        progressLabel.font = .systemFont(ofSize: 15)
        progressLabel.textColor = .secondaryLabel
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        cardContainer.backgroundColor = .secondarySystemBackground
        cardContainer.layer.cornerRadius = 16
        cardContainer.clipsToBounds = true
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardContainer)

        questionLabel.font = .systemFont(ofSize: 20, weight: .medium)
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(questionLabel)

        answerLabel.font = .systemFont(ofSize: 18)
        answerLabel.numberOfLines = 0
        answerLabel.textAlignment = .center
        answerLabel.textColor = .secondaryLabel
        answerLabel.isHidden = true
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(answerLabel)

        showAnswerButton.setTitle("Показать ответ", for: .normal)
        showAnswerButton.backgroundColor = AppConstants.accentColor
        showAnswerButton.setTitleColor(.white, for: .normal)
        showAnswerButton.layer.cornerRadius = 10
        showAnswerButton.addTarget(self, action: #selector(showAnswerTapped), for: .touchUpInside)
        showAnswerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showAnswerButton)

        ratingStack.axis = .horizontal
        ratingStack.distribution = .fillEqually
        ratingStack.spacing = 12
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ratingStack)

        hardButton.setTitle("Не помню", for: .normal)
        hardButton.backgroundColor = .systemRed
        hardButton.setTitleColor(.white, for: .normal)
        hardButton.layer.cornerRadius = 10
        hardButton.addTarget(self, action: #selector(ratingTapped(_:)), for: .touchUpInside)
        hardButton.tag = 0

        mediumButton.setTitle("Сложно", for: .normal)
        mediumButton.backgroundColor = .systemYellow
        mediumButton.setTitleColor(.black, for: .normal)
        mediumButton.layer.cornerRadius = 10
        mediumButton.addTarget(self, action: #selector(ratingTapped(_:)), for: .touchUpInside)
        mediumButton.tag = 1

        easyButton.setTitle("Легко", for: .normal)
        easyButton.backgroundColor = .systemGreen
        easyButton.setTitleColor(.white, for: .normal)
        easyButton.layer.cornerRadius = 10
        easyButton.addTarget(self, action: #selector(ratingTapped(_:)), for: .touchUpInside)
        easyButton.tag = 2

        ratingStack.addArrangedSubview(hardButton)
        ratingStack.addArrangedSubview(mediumButton)
        ratingStack.addArrangedSubview(easyButton)
        ratingStack.isHidden = true

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            progressLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cardContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cardContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            cardContainer.heightAnchor.constraint(equalToConstant: 220),

            questionLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -24),
            questionLabel.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),

            answerLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 24),
            answerLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -24),
            answerLabel.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),

            showAnswerButton.topAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: 24),
            showAnswerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            showAnswerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            showAnswerButton.heightAnchor.constraint(equalToConstant: 48),

            ratingStack.topAnchor.constraint(equalTo: showAnswerButton.bottomAnchor, constant: 20),
            ratingStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            ratingStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            ratingStack.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func updateContent() {
        let (cur, total) = output?.currentProgress() ?? (0, 0)
        progressLabel.text = "\(cur) из \(total)"
        questionLabel.text = output?.currentCardQuestion()
        answerLabel.text = output?.currentCardAnswer()
        let shown = output?.isAnswerShown() ?? false
        answerLabel.isHidden = !shown
        questionLabel.isHidden = shown
        showAnswerButton.isHidden = shown
        ratingStack.isHidden = !shown
    }

    @objc private func closeTapped() {
        output?.didTapClose()
    }

    @objc private func showAnswerTapped() {
        output?.didTapShowAnswer()
        flipCard()
    }

    private func flipCard() {
        isFlipped = true
        UIView.transition(with: cardContainer, duration: 0.35, options: .transitionFlipFromRight) { [weak self] in
            self?.updateContent()
        }
    }

    @objc private func ratingTapped(_ sender: UIButton) {
        let rating: LearningRating = sender.tag == 0 ? .hard : (sender.tag == 1 ? .medium : .easy)
        output?.didTapRating(rating)
        isFlipped = false
        UIView.transition(with: cardContainer, duration: 0.35, options: .transitionFlipFromLeft) { [weak self] in
            self?.updateContent()
        }
    }
}
