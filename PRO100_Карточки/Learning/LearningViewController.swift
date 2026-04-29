//
//  LearningViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - LearningViewInput
protocol LearningViewInput: AnyObject {
    func showCompletion(total: Int)
    func hideCompletion()
    func refreshContent()
    func setInteractionEnabled(_ enabled: Bool)
    func showErrorBanner(_ message: String)
}

// MARK: - LearningViewOutput
protocol LearningViewOutput: AnyObject {
    func viewDidLoad()
    func didTapClose()
    func didTapToggleAnswer()
    func didTapRating(_ rating: LearningRating)
    func didTapPrevious()
    func didTapNext()
    func didTapRestartLearning()
    func didTapBackToCardsFromCompletion()
    func didTapBackToSetsFromCompletion()
    func currentProgress() -> (current: Int, total: Int)
    func currentCardQuestion() -> String
    func currentCardAnswer() -> String
    func isAnswerShown() -> Bool
}

// MARK: - LearningRating
enum LearningRating {
    case hard
    case medium
    case easy
}

// MARK: - LearningViewController
final class LearningViewController: UIViewController, LearningViewInput {
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
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let completionOverlay = UIView()
    private let completionTitleLabel = UILabel()
    private let completionSubtitleLabel = UILabel()
    private let restartButton = UIButton(type: .system)
    private let backToCardsButton = UIButton(type: .system)
    private let backToSetsButton = UIButton(type: .system)
    private var isFlipped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
        updateContent()
    }

    private func setupUI() {
        view.backgroundColor = DS.bgTop

        let bgGrad = CAGradientLayer()
        bgGrad.colors = [DS.bgTop.cgColor, DS.bgMid.cgColor, DS.bgBot.cgColor]
        bgGrad.locations = [0, 0.55, 1]
        bgGrad.startPoint = CGPoint(x: 0.25, y: 0)
        bgGrad.endPoint   = CGPoint(x: 0.75, y: 1)
        bgGrad.frame = UIScreen.main.bounds
        view.layer.insertSublayer(bgGrad, at: 0)

        closeButton.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = DS.textDim
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        progressLabel.font = .app(15, .bold)
        progressLabel.textColor = DS.textDim
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        cardContainer.backgroundColor = DS.glass
        cardContainer.layer.cornerRadius = 28
        cardContainer.layer.cornerCurve  = .continuous
        cardContainer.layer.borderWidth  = 1
        cardContainer.layer.borderColor  = DS.glassBdr.cgColor
        cardContainer.layer.shadowColor  = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.45
        cardContainer.layer.shadowRadius  = 24
        cardContainer.layer.shadowOffset  = CGSize(width: 0, height: 12)
        cardContainer.clipsToBounds = false
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardContainer)

        questionLabel.font = .app(22, .bold)
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(questionLabel)

        answerLabel.font = .app(19, .semibold)
        answerLabel.numberOfLines = 0
        answerLabel.textAlignment = .center
        answerLabel.textColor = UIColor(red: 0.45, green: 0.72, blue: 1.0, alpha: 1)
        answerLabel.isHidden = true
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(answerLabel)

        showAnswerButton.setTitle("Показать ответ", for: .normal)
        showAnswerButton.backgroundColor = DS.royal
        showAnswerButton.setTitleColor(.white, for: .normal)
        showAnswerButton.titleLabel?.font = .app(17, .bold)
        showAnswerButton.layer.cornerRadius = 22
        showAnswerButton.layer.cornerCurve  = .continuous
        showAnswerButton.layer.shadowColor  = DS.royal.cgColor
        showAnswerButton.layer.shadowOpacity = 0.45
        showAnswerButton.layer.shadowRadius  = 14
        showAnswerButton.layer.shadowOffset  = CGSize(width: 0, height: 6)
        showAnswerButton.addTarget(self, action: #selector(showAnswerTapped), for: .touchUpInside)
        showAnswerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showAnswerButton)

        ratingStack.axis = .horizontal
        ratingStack.distribution = .fillEqually
        ratingStack.spacing = 12
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ratingStack)

        func ratingBtn(title: String, color: UIColor) -> UIButton {
            let b = UIButton(type: .system)
            b.setTitle(title, for: .normal)
            b.setTitleColor(.white, for: .normal)
            b.titleLabel?.font = .app(15, .bold)
            b.backgroundColor = color
            b.layer.cornerRadius = 20
            b.layer.cornerCurve  = .continuous
            b.layer.shadowColor  = color.cgColor
            b.layer.shadowOpacity = 0.45
            b.layer.shadowRadius  = 10
            b.layer.shadowOffset  = CGSize(width: 0, height: 5)
            return b
        }

        let hb = hardButton; let mb = mediumButton; let eb = easyButton
        let hb2 = ratingBtn(title: "Не помню",  color: DS.crimson)
        let mb2 = ratingBtn(title: "Сложно",    color: UIColor(red: 0.9, green: 0.65, blue: 0.0, alpha: 1))
        let eb2 = ratingBtn(title: "Легко",     color: UIColor(red: 0.1, green: 0.72, blue: 0.35, alpha: 1))
        hb.setTitle("Не помню", for: .normal); hb.setTitleColor(.white, for: .normal)
        hb.titleLabel?.font = .app(15, .bold)
        hb.backgroundColor = DS.crimson
        hb.layer.cornerRadius = 20; hb.layer.cornerCurve = .continuous
        hb.layer.shadowColor = DS.crimson.cgColor; hb.layer.shadowOpacity = 0.45
        hb.layer.shadowRadius = 10; hb.layer.shadowOffset = CGSize(width: 0, height: 5)
        hb.addTarget(self, action: #selector(ratingTapped(_:)), for: .touchUpInside)
        hb.tag = 0
        mb.setTitle("Сложно", for: .normal); mb.setTitleColor(.white, for: .normal)
        mb.titleLabel?.font = .app(15, .bold)
        mb.backgroundColor = UIColor(red: 0.9, green: 0.65, blue: 0.0, alpha: 1)
        mb.layer.cornerRadius = 20; mb.layer.cornerCurve = .continuous
        mb.addTarget(self, action: #selector(ratingTapped(_:)), for: .touchUpInside)
        mb.tag = 1
        eb.setTitle("Легко", for: .normal); eb.setTitleColor(.white, for: .normal)
        eb.titleLabel?.font = .app(15, .bold)
        eb.backgroundColor = UIColor(red: 0.1, green: 0.72, blue: 0.35, alpha: 1)
        eb.layer.cornerRadius = 20; eb.layer.cornerCurve = .continuous
        eb.layer.shadowColor = UIColor(red: 0.1, green: 0.72, blue: 0.35, alpha: 1).cgColor
        eb.layer.shadowOpacity = 0.45; eb.layer.shadowRadius = 10
        eb.layer.shadowOffset = CGSize(width: 0, height: 5)
        eb.addTarget(self, action: #selector(ratingTapped(_:)), for: .touchUpInside)
        eb.tag = 2
        _ = hb2; _ = mb2; _ = eb2

        ratingStack.addArrangedSubview(hardButton)
        ratingStack.addArrangedSubview(mediumButton)
        ratingStack.addArrangedSubview(easyButton)
        ratingStack.isHidden = true

        previousButton.setTitle("← Назад", for: .normal)
        previousButton.setTitleColor(DS.textDim, for: .normal)
        previousButton.titleLabel?.font = .app(15, .semibold)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previousButton)

        nextButton.setTitle("Вперёд →", for: .normal)
        nextButton.setTitleColor(DS.textDim, for: .normal)
        nextButton.titleLabel?.font = .app(15, .semibold)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)

        let tapCard = UITapGestureRecognizer(target: self, action: #selector(showAnswerTapped))
        cardContainer.addGestureRecognizer(tapCard)
        cardContainer.isUserInteractionEnabled = true

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(nextTapped))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(previousTapped))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        completionOverlay.backgroundColor = DS.bgTop
        completionOverlay.isHidden = true
        completionOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completionOverlay)

        let overlayGrad = CAGradientLayer()
        overlayGrad.colors  = [DS.bgTop.cgColor, DS.bgMid.cgColor]
        overlayGrad.frame   = UIScreen.main.bounds
        overlayGrad.startPoint = CGPoint(x: 0, y: 0)
        overlayGrad.endPoint   = CGPoint(x: 1, y: 1)
        completionOverlay.layer.insertSublayer(overlayGrad, at: 0)

        completionTitleLabel.text = "🎉 Набор завершён"
        completionTitleLabel.font = .app(30, .black)
        completionTitleLabel.textColor = .white
        completionTitleLabel.textAlignment = .center
        completionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        completionOverlay.addSubview(completionTitleLabel)

        completionSubtitleLabel.font = .app(16, .medium)
        completionSubtitleLabel.textColor = DS.textDim
        completionSubtitleLabel.textAlignment = .center
        completionSubtitleLabel.numberOfLines = 0
        completionSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        completionOverlay.addSubview(completionSubtitleLabel)

        restartButton.setTitle("Повторить набор", for: .normal)
        restartButton.backgroundColor = DS.royal
        restartButton.setTitleColor(.white, for: .normal)
        restartButton.titleLabel?.font = .app(17, .bold)
        restartButton.layer.cornerRadius = 22
        restartButton.layer.cornerCurve  = .continuous
        restartButton.layer.shadowColor  = DS.royal.cgColor
        restartButton.layer.shadowOpacity = 0.45
        restartButton.layer.shadowRadius  = 14
        restartButton.layer.shadowOffset  = CGSize(width: 0, height: 6)
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        completionOverlay.addSubview(restartButton)

        backToCardsButton.setTitle("К карточкам набора", for: .normal)
        backToCardsButton.setTitleColor(DS.textDim, for: .normal)
        backToCardsButton.titleLabel?.font = .app(15, .semibold)
        backToCardsButton.addTarget(self, action: #selector(backToCardsTapped), for: .touchUpInside)
        backToCardsButton.translatesAutoresizingMaskIntoConstraints = false
        completionOverlay.addSubview(backToCardsButton)

        backToSetsButton.setTitle("К наборам", for: .normal)
        backToSetsButton.setTitleColor(.white, for: .normal)
        backToSetsButton.titleLabel?.font = .app(17, .bold)
        backToSetsButton.backgroundColor = DS.glass
        backToSetsButton.layer.cornerRadius = 22
        backToSetsButton.layer.cornerCurve  = .continuous
        backToSetsButton.layer.borderWidth   = 1
        backToSetsButton.layer.borderColor   = DS.glassBdr.cgColor
        backToSetsButton.addTarget(self, action: #selector(backToSetsTapped), for: .touchUpInside)
        backToSetsButton.translatesAutoresizingMaskIntoConstraints = false
        completionOverlay.addSubview(backToSetsButton)

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
            ratingStack.heightAnchor.constraint(equalToConstant: 48),

            previousButton.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 14),
            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nextButton.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 14),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            completionOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            completionOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            completionOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            completionOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            completionTitleLabel.centerXAnchor.constraint(equalTo: completionOverlay.centerXAnchor),
            completionTitleLabel.centerYAnchor.constraint(equalTo: completionOverlay.centerYAnchor, constant: -80),
            completionTitleLabel.leadingAnchor.constraint(equalTo: completionOverlay.leadingAnchor, constant: 24),
            completionTitleLabel.trailingAnchor.constraint(equalTo: completionOverlay.trailingAnchor, constant: -24),

            completionSubtitleLabel.topAnchor.constraint(equalTo: completionTitleLabel.bottomAnchor, constant: 12),
            completionSubtitleLabel.leadingAnchor.constraint(equalTo: completionOverlay.leadingAnchor, constant: 24),
            completionSubtitleLabel.trailingAnchor.constraint(equalTo: completionOverlay.trailingAnchor, constant: -24),

            restartButton.topAnchor.constraint(equalTo: completionSubtitleLabel.bottomAnchor, constant: 24),
            restartButton.leadingAnchor.constraint(equalTo: completionOverlay.leadingAnchor, constant: 24),
            restartButton.trailingAnchor.constraint(equalTo: completionOverlay.trailingAnchor, constant: -24),
            restartButton.heightAnchor.constraint(equalToConstant: 48),

            backToCardsButton.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 14),
            backToCardsButton.leadingAnchor.constraint(equalTo: completionOverlay.leadingAnchor, constant: 24),
            backToCardsButton.trailingAnchor.constraint(equalTo: completionOverlay.trailingAnchor, constant: -24),
            backToCardsButton.heightAnchor.constraint(equalToConstant: 44),

            backToSetsButton.topAnchor.constraint(equalTo: backToCardsButton.bottomAnchor, constant: 12),
            backToSetsButton.leadingAnchor.constraint(equalTo: completionOverlay.leadingAnchor, constant: 24),
            backToSetsButton.trailingAnchor.constraint(equalTo: completionOverlay.trailingAnchor, constant: -24),
            backToSetsButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func updateContent() {
        let (cur, total) = output?.currentProgress() ?? (0, 0)
        progressLabel.text = "\(cur) из \(total)"
        nextButton.setTitle(cur == total ? "Завершить" : "Вперед", for: .normal)
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
        let wasShown = output?.isAnswerShown() ?? false
        output?.didTapToggleAnswer()
        flipCard(showingAnswer: !wasShown)
    }

    private func flipCard(showingAnswer: Bool) {
        isFlipped = true
        let option: UIView.AnimationOptions = showingAnswer ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: cardContainer, duration: 0.35, options: option) { [weak self] in
            self?.updateContent()
        }
    }

    @objc private func ratingTapped(_ sender: UIButton) {
        let rating: LearningRating = sender.tag == 0 ? .hard : (sender.tag == 1 ? .medium : .easy)
        animateMoveToAdjacentCard(isNext: true) { [weak self] in
            self?.output?.didTapRating(rating)
        }
    }

    @objc private func previousTapped() {
        animateMoveToAdjacentCard(isNext: false) { [weak self] in
            self?.output?.didTapPrevious()
        }
    }

    @objc private func nextTapped() {
        animateMoveToAdjacentCard(isNext: true) { [weak self] in
            self?.output?.didTapNext()
        }
    }

    @objc private func restartTapped() {
        output?.didTapRestartLearning()
        hideCompletion()
        updateContent()
    }

    @objc private func backToCardsTapped() {
        output?.didTapBackToCardsFromCompletion()
        hideCompletion()
        updateContent()
    }

    @objc private func backToSetsTapped() {
        output?.didTapBackToSetsFromCompletion()
    }

    private func animateMoveToAdjacentCard(isNext: Bool, updateModel: @escaping () -> Void) {
        let before = output?.currentProgress().current ?? 0
        let direction: CGFloat = isNext ? -1 : 1

        UIView.animate(withDuration: 0.2, animations: {
            self.cardContainer.transform = CGAffineTransform(translationX: direction * 60, y: 0)
            self.cardContainer.alpha = 0
        }) { _ in
            updateModel()
            if !(self.completionOverlay.isHidden) {
                self.cardContainer.transform = .identity
                self.cardContainer.alpha = 1
                return
            }
            let after = self.output?.currentProgress().current ?? 0
            guard before != after else {
                self.cardContainer.transform = .identity
                self.cardContainer.alpha = 1
                return
            }

            self.isFlipped = false
            self.updateContent()
            self.cardContainer.transform = CGAffineTransform(translationX: -direction * 60, y: 0)
            self.cardContainer.alpha = 0
            UIView.animate(withDuration: 0.22) {
                self.cardContainer.transform = .identity
                self.cardContainer.alpha = 1
            }
        }
    }

    func showCompletion(total: Int) {
        completionSubtitleLabel.text = "Вы прошли все \(total) карточек.\nПовторите набор, вернитесь к списку карточек набора или к выбору набора."
        completionOverlay.alpha = 0
        completionOverlay.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.completionOverlay.alpha = 1
        }
    }

    func hideCompletion() {
        completionOverlay.isHidden = true
        completionOverlay.alpha = 0
    }

    func refreshContent() {
        updateContent()
    }

    func setInteractionEnabled(_ enabled: Bool) {
        showAnswerButton.isEnabled = enabled
        hardButton.isEnabled = enabled
        mediumButton.isEnabled = enabled
        easyButton.isEnabled = enabled
        previousButton.isEnabled = enabled
        nextButton.isEnabled = enabled
    }

    func showErrorBanner(_ message: String) {
        showTopBanner(message)
    }
}
