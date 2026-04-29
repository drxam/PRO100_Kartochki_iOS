//
//  ForgotPasswordViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - ForgotPasswordViewInput
protocol ForgotPasswordViewInput: AnyObject {
    func setLoading(_ isLoading: Bool)
    func showStatusMessage(_ message: String, isError: Bool)
}

// MARK: - ForgotPasswordViewOutput
protocol ForgotPasswordViewOutput: AnyObject {
    func viewDidLoad()
    func didTapSend(email: String)
    func didTapBackToLogin()
}

// MARK: - ForgotPasswordViewController
final class ForgotPasswordViewController: UIViewController {
    var output: ForgotPasswordViewOutput?

    private let bgLayer = CAGradientLayer()
    private let orbA    = UIView()
    private let orbB    = UIView()
    private let orbC    = UIView()

    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()

    private let card    = UIView()
    private let blur    = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let cardBorder = CAGradientLayer()
    private let emailField  = AuthFieldRow(icon: "envelope.fill", placeholder: "Электронная почта")
    private let sendBtn     = GradientButton()
    private let statusLabel = UILabel()
    private let backBtn     = UIButton(type: .system)
    private let spinner     = UIActivityIndicatorView(style: .medium)

    private var cardRestCenterY: CGFloat = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildBackground()
        buildHero()
        buildCard()
        buildConstraints()
        setupKeyboard()
        output?.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cardRestCenterY == 0 { cardRestCenterY = card.center.y }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgLayer.frame = view.bounds
        layoutAppOrbs(orbA, orbB, orbC, in: view)
        layoutCardBorder()
    }


    private func buildBackground() {
        applyAppBackground(to: view, bgLayer: bgLayer, orbA: orbA, orbB: orbB, orbC: orbC)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKb))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }


    private func buildHero() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.attributedText = NSAttributedString(
            string: "Восстановление",
            attributes: [.font: UIFont.app(34, .black), .foregroundColor: UIColor.white, .kern: -0.5]
        )
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.attributedText = NSAttributedString(
            string: "Мы отправим ссылку для сброса пароля на указанный email",
            attributes: [.font: UIFont.app(15, .medium), .foregroundColor: DS.textDim]
        )
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
    }


    private func buildCard() {
        let (c, b) = makeAuthCard()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor   = c.backgroundColor
        card.layer.cornerRadius = c.layer.cornerRadius
        card.layer.cornerCurve  = c.layer.cornerCurve
        card.layer.shadowColor  = c.layer.shadowColor
        card.layer.shadowOpacity = c.layer.shadowOpacity
        card.layer.shadowRadius  = c.layer.shadowRadius
        card.layer.shadowOffset  = c.layer.shadowOffset

        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 32
        blur.layer.cornerCurve  = .continuous
        blur.clipsToBounds = true

        view.addSubview(card)
        card.addSubview(blur)
        _ = b

        emailField.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(emailField)

        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.setTitle("Отправить ссылку", for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.titleLabel?.font = .app(17, .black)
        sendBtn.layer.shadowColor   = DS.crimson.cgColor
        sendBtn.layer.shadowOpacity = 0.5
        sendBtn.layer.shadowRadius  = 16
        sendBtn.layer.shadowOffset  = CGSize(width: 0, height: 6)
        sendBtn.addTarget(self, action: #selector(sendTap), for: .touchUpInside)
        sendBtn.addTarget(self, action: #selector(pressDown), for: [.touchDown, .touchDragEnter])
        sendBtn.addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        card.addSubview(sendBtn)

        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.addSubview(spinner)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .app(13, .semibold)
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.isHidden = true
        card.addSubview(statusLabel)

        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.setTitle("← Вернуться ко входу", for: .normal)
        backBtn.setTitleColor(DS.textDim, for: .normal)
        backBtn.titleLabel?.font = .app(15, .semibold)
        backBtn.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        card.addSubview(backBtn)
    }

    private func layoutCardBorder() {
        let r: CGFloat = 32
        cardBorder.frame = card.bounds
        cardBorder.cornerRadius = r
        cardBorder.cornerCurve  = .continuous
        cardBorder.colors = [
            UIColor.white.withAlphaComponent(0.45).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor,
            DS.crimson.withAlphaComponent(0.35).cgColor,
            DS.royal.withAlphaComponent(0.20).cgColor,
        ]
        cardBorder.locations  = [0, 0.4, 0.75, 1]
        cardBorder.startPoint = CGPoint(x: 0, y: 0)
        cardBorder.endPoint   = CGPoint(x: 1, y: 1)

        let mask = CAShapeLayer()
        let outer = UIBezierPath(roundedRect: card.bounds, byRoundingCorners: .allCorners,
                                 cornerRadii: CGSize(width: r, height: r))
        let inner = UIBezierPath(roundedRect: card.bounds.insetBy(dx: 1.2, dy: 1.2),
                                 byRoundingCorners: .allCorners,
                                 cornerRadii: CGSize(width: r - 1, height: r - 1))
        outer.append(inner)
        mask.path = outer.cgPath
        mask.fillRule = .evenOdd
        cardBorder.mask = mask

        if cardBorder.superlayer == nil { card.layer.addSublayer(cardBorder) }
    }


    private func buildConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            card.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            blur.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            blur.topAnchor.constraint(equalTo: card.topAnchor),
            blur.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            emailField.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            emailField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 56),

            sendBtn.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            sendBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            sendBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            sendBtn.heightAnchor.constraint(equalToConstant: 52),

            spinner.centerXAnchor.constraint(equalTo: sendBtn.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: sendBtn.centerYAnchor),

            statusLabel.topAnchor.constraint(equalTo: sendBtn.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            backBtn.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 14),
            backBtn.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            backBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28),
        ])
    }


    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func dismissKb() { view.endEditing(true) }

    @objc private func kbShow(_ n: Notification) {
        guard let info = n.userInfo,
              let kbFrame  = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let rawCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        let kbTop     = view.bounds.height - kbFrame.height
        let safeTop   = view.safeAreaInsets.top
        let idealTop  = safeTop + (kbTop - safeTop - card.bounds.height) / 2
        let offset    = cardRestCenterY - card.bounds.height / 2 - idealTop
        let opts      = UIView.AnimationOptions(rawValue: rawCurve << 16).union(.beginFromCurrentState)
        UIView.animate(withDuration: duration, delay: 0, options: opts) {
            self.titleLabel.alpha    = 0
            self.subtitleLabel.alpha = 0
            self.card.transform      = CGAffineTransform(translationX: 0, y: -offset)
        }
    }

    @objc private func kbHide(_ n: Notification) {
        guard let info = n.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let rawCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        let opts = UIView.AnimationOptions(rawValue: rawCurve << 16).union(.beginFromCurrentState)
        UIView.animate(withDuration: duration, delay: 0, options: opts) {
            self.titleLabel.alpha    = 1
            self.subtitleLabel.alpha = 1
            self.card.transform      = .identity
        }
    }


    @objc private func sendTap()  { output?.didTapSend(email: emailField.value) }
    @objc private func backTap()  { output?.didTapBackToLogin() }

    @objc private func pressDown() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.sendBtn.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func pressUp() {
        UIView.animate(withDuration: 0.22, delay: 0,
                       usingSpringWithDamping: 0.55, initialSpringVelocity: 8,
                       options: [.allowUserInteraction]) {
            self.sendBtn.transform = .identity
        }
    }
}


// MARK: - ForgotPasswordViewController Extension
extension ForgotPasswordViewController: ForgotPasswordViewInput {
    func setLoading(_ isLoading: Bool) {
        sendBtn.isEnabled = !isLoading
        backBtn.isEnabled = !isLoading
        sendBtn.setTitle(isLoading ? "" : "Отправить ссылку", for: .normal)
        isLoading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    func showStatusMessage(_ message: String, isError: Bool) {
        statusLabel.isHidden = message.isEmpty
        statusLabel.textColor = isError
            ? UIColor(red: 1, green: 0.55, blue: 0.55, alpha: 1)
            : UIColor(red: 0.55, green: 1, blue: 0.65, alpha: 1)
        statusLabel.text = message
        guard !message.isEmpty else { return }
        if isError {
            let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            anim.duration = 0.45
            anim.values = [0, -10, 10, -8, 8, -4, 4, 0]
            card.layer.add(anim, forKey: "shake")
        }
    }
}
