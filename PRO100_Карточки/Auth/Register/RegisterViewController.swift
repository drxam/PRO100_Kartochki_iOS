//
//  RegisterViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol RegisterViewInput: AnyObject {
    func setLoading(_ isLoading: Bool)
    func showMessage(_ message: String)
    func setPasswordValidation(lengthOK: Bool, lettersDigitsOK: Bool)
}

protocol RegisterViewOutput: AnyObject {
    func viewDidLoad()
    func didTapRegister(email: String, password: String, confirmPassword: String)
    func didTapLogin()
    func didChangePassword(_ password: String)
}

final class RegisterViewController: UIViewController, RegisterViewInput {
    var output: RegisterViewOutput?

    // Background
    private let bgLayer = CAGradientLayer()
    private let orbA    = UIView()
    private let orbB    = UIView()
    private let orbC    = UIView()

    // Scroll (needed: more fields than can fit without keyboard)
    private let scroll  = UIScrollView()
    private let content = UIView()

    // Hero
    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()

    // Card
    private let card       = UIView()
    private let blur       = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let cardBorder = CAGradientLayer()

    private let emailField   = AuthFieldRow(icon: "envelope.fill", placeholder: "Электронная почта")
    private let passField    = AuthFieldRow(icon: "lock.fill", placeholder: "Пароль", secure: true)
    private let confirmField = AuthFieldRow(icon: "lock.shield.fill", placeholder: "Подтверждение пароля", secure: true)
    private let eyeBtn       = UIButton(type: .system)
    private let eyeBtn2      = UIButton(type: .system)

    private let lengthRow    = ValidationRow("Минимум \(ValidationRules.minPasswordLength) символов")
    private let complexRow   = ValidationRow("Буквы и цифры")

    private let registerBtn  = GradientButton()
    private let divider      = AuthDivider()
    private let loginBtn     = UIButton(type: .system)
    private let errorLabel   = UILabel()
    private let spinner      = UIActivityIndicatorView(style: .medium)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildBackground()
        buildScroll()
        buildHero()
        buildCard()
        buildConstraints()
        output?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgLayer.frame = view.bounds
        layoutAppOrbs(orbA, orbB, orbC, in: view)
        layoutCardBorder()
    }

    // MARK: - Background

    private func buildBackground() {
        applyAppBackground(to: view, bgLayer: bgLayer, orbA: orbA, orbB: orbB, orbC: orbC)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKb))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Scroll

    private func buildScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .interactive
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(content)
    }

    // MARK: - Hero

    private func buildHero() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.attributedText = NSAttributedString(
            string: "Создание\nаккаунта",
            attributes: [.font: UIFont.app(34, .black), .foregroundColor: UIColor.white, .kern: -0.5]
        )
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.attributedText = NSAttributedString(
            string: "Зарегистрируйтесь, чтобы сохранять и изучать наборы",
            attributes: [.font: UIFont.app(15, .medium), .foregroundColor: DS.textDim]
        )
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        content.addSubview(titleLabel)
        content.addSubview(subtitleLabel)
    }

    // MARK: - Card

    private func buildCard() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor   = DS.glass
        card.layer.cornerRadius = 32
        card.layer.cornerCurve  = .continuous
        card.layer.shadowColor  = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.55
        card.layer.shadowRadius  = 32
        card.layer.shadowOffset  = CGSize(width: 0, height: 16)

        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 32
        blur.layer.cornerCurve  = .continuous
        blur.clipsToBounds = true

        content.addSubview(card)
        card.addSubview(blur)

        // Fields
        emailField.translatesAutoresizingMaskIntoConstraints   = false
        passField.translatesAutoresizingMaskIntoConstraints    = false
        confirmField.translatesAutoresizingMaskIntoConstraints = false
        passField.addEditingTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        card.addSubview(emailField)
        card.addSubview(passField)
        card.addSubview(confirmField)

        func makeEye() -> UIButton {
            let b = UIButton(type: .system)
            b.setImage(UIImage(systemName: "eye.slash.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
            b.tintColor = DS.textDim
            b.translatesAutoresizingMaskIntoConstraints = false
            return b
        }
        let eye1 = eyeBtn; let eye2 = eyeBtn2
        eye1.setImage(UIImage(systemName: "eye.slash.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        eye1.tintColor = DS.textDim
        eye1.translatesAutoresizingMaskIntoConstraints = false
        eye1.addTarget(self, action: #selector(togglePass1), for: .touchUpInside)
        eye2.setImage(UIImage(systemName: "eye.slash.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        eye2.tintColor = DS.textDim
        eye2.translatesAutoresizingMaskIntoConstraints = false
        eye2.addTarget(self, action: #selector(togglePass2), for: .touchUpInside)
        card.addSubview(eye1)
        card.addSubview(eye2)
        _ = makeEye()

        // Validation rows
        lengthRow.translatesAutoresizingMaskIntoConstraints  = false
        complexRow.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(lengthRow)
        card.addSubview(complexRow)

        // Register button
        registerBtn.translatesAutoresizingMaskIntoConstraints = false
        registerBtn.setTitle("Зарегистрироваться", for: .normal)
        registerBtn.setTitleColor(.white, for: .normal)
        registerBtn.titleLabel?.font = .app(17, .black)
        registerBtn.layer.shadowColor   = DS.crimson.cgColor
        registerBtn.layer.shadowOpacity = 0.5
        registerBtn.layer.shadowRadius  = 16
        registerBtn.layer.shadowOffset  = CGSize(width: 0, height: 6)
        registerBtn.addTarget(self, action: #selector(regTap), for: .touchUpInside)
        registerBtn.addTarget(self, action: #selector(pressDown), for: [.touchDown, .touchDragEnter])
        registerBtn.addTarget(self, action: #selector(pressUp),
                              for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        card.addSubview(registerBtn)

        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        registerBtn.addSubview(spinner)

        // Error
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = .app(13, .semibold)
        errorLabel.textColor = UIColor(red: 1, green: 0.55, blue: 0.55, alpha: 1)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        card.addSubview(errorLabel)

        // Divider + login
        divider.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(divider)

        loginBtn.translatesAutoresizingMaskIntoConstraints = false
        loginBtn.setTitle("Уже есть аккаунт? Войти", for: .normal)
        loginBtn.setTitleColor(DS.textDim, for: .normal)
        loginBtn.titleLabel?.font = .app(15, .semibold)
        loginBtn.addTarget(self, action: #selector(loginTap), for: .touchUpInside)
        card.addSubview(loginBtn)
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

    // MARK: - Constraints

    private func buildConstraints() {
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor),

            titleLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 64),
            titleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),

            card.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            card.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -32),

            blur.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            blur.topAnchor.constraint(equalTo: card.topAnchor),
            blur.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            emailField.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            emailField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 56),

            passField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 14),
            passField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            passField.trailingAnchor.constraint(equalTo: eyeBtn.leadingAnchor, constant: -4),
            passField.heightAnchor.constraint(equalToConstant: 56),

            eyeBtn.centerYAnchor.constraint(equalTo: passField.centerYAnchor),
            eyeBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            eyeBtn.widthAnchor.constraint(equalToConstant: 36),
            eyeBtn.heightAnchor.constraint(equalToConstant: 36),

            confirmField.topAnchor.constraint(equalTo: passField.bottomAnchor, constant: 14),
            confirmField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            confirmField.trailingAnchor.constraint(equalTo: eyeBtn2.leadingAnchor, constant: -4),
            confirmField.heightAnchor.constraint(equalToConstant: 56),

            eyeBtn2.centerYAnchor.constraint(equalTo: confirmField.centerYAnchor),
            eyeBtn2.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            eyeBtn2.widthAnchor.constraint(equalToConstant: 36),
            eyeBtn2.heightAnchor.constraint(equalToConstant: 36),

            lengthRow.topAnchor.constraint(equalTo: confirmField.bottomAnchor, constant: 12),
            lengthRow.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            lengthRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            complexRow.topAnchor.constraint(equalTo: lengthRow.bottomAnchor, constant: 4),
            complexRow.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            complexRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            registerBtn.topAnchor.constraint(equalTo: complexRow.bottomAnchor, constant: 20),
            registerBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            registerBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            registerBtn.heightAnchor.constraint(equalToConstant: 52),

            spinner.centerXAnchor.constraint(equalTo: registerBtn.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: registerBtn.centerYAnchor),

            errorLabel.topAnchor.constraint(equalTo: registerBtn.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            divider.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 14),
            divider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            loginBtn.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 14),
            loginBtn.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            loginBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28),
        ])
    }

    // MARK: - Actions

    @objc private func dismissKb()  { view.endEditing(true) }
    @objc private func regTap()     { output?.didTapRegister(email: emailField.value, password: passField.value, confirmPassword: confirmField.value) }
    @objc private func loginTap()   { output?.didTapLogin() }
    @objc private func passwordChanged() { output?.didChangePassword(passField.value) }

    @objc private func togglePass1() {
        passField.toggleSecure()
        let show = !passField.isSecure
        eyeBtn.setImage(UIImage(systemName: show ? "eye.fill" : "eye.slash.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    @objc private func togglePass2() {
        confirmField.toggleSecure()
        let show = !confirmField.isSecure
        eyeBtn2.setImage(UIImage(systemName: show ? "eye.fill" : "eye.slash.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    @objc private func pressDown() {
        UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.registerBtn.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func pressUp() {
        UIView.animate(withDuration: 0.22, delay: 0,
                       usingSpringWithDamping: 0.55, initialSpringVelocity: 8,
                       options: [.allowUserInteraction]) {
            self.registerBtn.transform = .identity
        }
    }

    // MARK: - RegisterViewInput

    func setLoading(_ isLoading: Bool) {
        registerBtn.isEnabled = !isLoading
        loginBtn.isEnabled    = !isLoading
        registerBtn.setTitle(isLoading ? "" : "Зарегистрироваться", for: .normal)
        isLoading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    func showMessage(_ message: String) {
        errorLabel.text    = message
        errorLabel.isHidden = message.isEmpty
        guard !message.isEmpty else { return }
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.45
        anim.values = [0, -10, 10, -8, 8, -4, 4, 0]
        card.layer.add(anim, forKey: "shake")
    }

    func setPasswordValidation(lengthOK: Bool, lettersDigitsOK: Bool) {
        lengthRow.setValid(lengthOK)
        complexRow.setValid(lettersDigitsOK)
    }
}
