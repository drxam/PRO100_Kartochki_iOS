//
//  LoginViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - LoginViewInput
protocol LoginViewInput: AnyObject {
    func setLoading(_ isLoading: Bool)
    func showMessage(_ message: String)
}

// MARK: - LoginViewOutput
protocol LoginViewOutput: AnyObject {
    func viewDidLoad()
    func didTapLogin(email: String, password: String)
    func didTapForgotPassword()
    func didTapRegister()
}


// MARK: - LoginViewController
final class LoginViewController: UIViewController {
    var output: LoginViewOutput?

    private let bgLayer       = CAGradientLayer()
    private let orbA          = UIView()
    private let orbB          = UIView()
    private let orbC          = UIView()
    private let rings         = CAShapeLayer()

    private let logoLabel     = UILabel()
    private let taglineLabel  = UILabel()

    private let card          = UIView()
    private let cardBlur      = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let cardBorder    = CAGradientLayer()

    private let emailField    = AuthFieldRow(icon: "envelope.fill", placeholder: "Электронная почта")
    private let passField     = AuthFieldRow(icon: "lock.fill", placeholder: "Пароль", secure: true)
    private let eyeBtn        = UIButton(type: .system)

    private let loginBtn      = GradientButton()
    private let divider       = AuthDivider()
    private let registerBtn   = UIButton(type: .system)
    private let forgotBtn     = UIButton(type: .system)

    private let errorLabel    = UILabel()
    private let spinner       = UIActivityIndicatorView(style: .medium)

    private var cardRestCenterY: CGFloat = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildBackground()
        buildHero()
        buildCard()
        buildConstraints()
        output?.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cardRestCenterY == 0 {
            cardRestCenterY = card.center.y
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgLayer.frame = view.bounds
        layoutOrbs()
        layoutRings()
        layoutCardGradBorder()
    }


    private func buildBackground() {
        bgLayer.colors   = [DS.bgTop.cgColor, DS.bgMid.cgColor, DS.bgBot.cgColor]
        bgLayer.locations = [0, 0.52, 1]
        bgLayer.startPoint = CGPoint(x: 0.25, y: 0)
        bgLayer.endPoint   = CGPoint(x: 0.75, y: 1)
        view.layer.insertSublayer(bgLayer, at: 0)

        rings.fillColor   = UIColor.clear.cgColor
        rings.strokeColor = UIColor.white.withAlphaComponent(0.05).cgColor
        rings.lineWidth   = 1
        view.layer.insertSublayer(rings, at: 1)

        configOrb(orbA, fill: UIColor.white.withAlphaComponent(0.14), glow: UIColor.white)
        configOrb(orbB, fill: DS.royal.withAlphaComponent(0.22), glow: DS.royal)
        configOrb(orbC, fill: DS.crimson.withAlphaComponent(0.18), glow: DS.crimson)
        [orbA, orbB, orbC].forEach { view.addSubview($0) }
    }

    private func configOrb(_ v: UIView, fill: UIColor, glow: UIColor) {
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = fill
        v.layer.shadowColor   = glow.cgColor
        v.layer.shadowOpacity = 0.85
        v.layer.shadowRadius  = 55
        v.layer.shadowOffset  = .zero
    }

    private func layoutOrbs() {
        let w = view.bounds.width; let h = view.bounds.height
        placeOrb(orbA, cx: w * 0.85, cy: h * 0.07, r: 90)
        placeOrb(orbB, cx: w * 0.10, cy: h * 0.40, r: 110)
        placeOrb(orbC, cx: w * 0.90, cy: h * 0.88, r: 100)
    }

    private func placeOrb(_ v: UIView, cx: CGFloat, cy: CGFloat, r: CGFloat) {
        v.frame = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
        v.layer.cornerRadius = r
    }

    private func layoutRings() {
        let cx = view.bounds.midX
        let cy = view.bounds.height * 0.30
        let path = UIBezierPath()
        stride(from: CGFloat(100), through: 320, by: 70).forEach { r in
            path.append(UIBezierPath(arcCenter: CGPoint(x: cx, y: cy),
                                     radius: r, startAngle: 0, endAngle: .pi * 2, clockwise: true))
        }
        rings.path = path.cgPath
    }


    private func buildHero() {
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.font = .app(38, .black)
        logoLabel.textColor = .white
        logoLabel.textAlignment = .center
        logoLabel.numberOfLines = 1
        logoLabel.adjustsFontSizeToFitWidth = true
        logoLabel.minimumScaleFactor = 0.65
        logoLabel.attributedText = NSAttributedString(
            string: "PRO100_Карточки",
            attributes: [
                .font: UIFont.app(38, .black),
                .foregroundColor: UIColor.white,
                .kern: -0.5
            ]
        )

        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        taglineLabel.attributedText = NSAttributedString(
            string: "У Ч И · З А П О М И Н А Й · П О В Т О Р Я Й",
            attributes: [
                .font: UIFont.app(10, .bold),
                .foregroundColor: DS.textDim,
                .kern: 2.5
            ]
        )
        taglineLabel.textAlignment = .center

        view.addSubview(logoLabel)
        view.addSubview(taglineLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let info     = n.userInfo,
              let kbFrame  = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let rawCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let kbTop       = view.bounds.height - kbFrame.height
        let safeTop     = view.safeAreaInsets.top
        let available   = kbTop - safeTop
        let idealTop    = safeTop + (available - card.bounds.height) / 2
        let originalTop = cardRestCenterY - card.bounds.height / 2
        let offset      = originalTop - idealTop

        let opts = UIView.AnimationOptions(rawValue: rawCurve << 16).union(.beginFromCurrentState)
        UIView.animate(withDuration: duration, delay: 0, options: opts) {
            self.logoLabel.alpha        = 0
            self.taglineLabel.alpha     = 0
            self.logoLabel.transform    = CGAffineTransform(translationX: 0, y: -10)
            self.taglineLabel.transform = CGAffineTransform(translationX: 0, y: -10)
            self.card.transform         = CGAffineTransform(translationX: 0, y: -offset)
        }
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        guard let info     = n.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let rawCurve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let opts = UIView.AnimationOptions(rawValue: rawCurve << 16).union(.beginFromCurrentState)
        UIView.animate(withDuration: duration, delay: 0, options: opts) {
            self.logoLabel.alpha        = 1
            self.taglineLabel.alpha     = 1
            self.logoLabel.transform    = .identity
            self.taglineLabel.transform = .identity
            self.card.transform         = .identity
        }
    }


    private func buildCard() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = DS.glass
        card.layer.cornerRadius = 32
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor  = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.55
        card.layer.shadowRadius  = 32
        card.layer.shadowOffset  = CGSize(width: 0, height: 16)

        cardBlur.translatesAutoresizingMaskIntoConstraints = false
        cardBlur.layer.cornerRadius = 32
        cardBlur.layer.cornerCurve  = .continuous
        cardBlur.clipsToBounds = true

        view.addSubview(card)
        card.addSubview(cardBlur)

        buildFields()
        buildLoginBtn()
        buildBottomLinks()
        buildFeedback()
    }

    private func layoutCardGradBorder() {
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
        cardBorder.locations = [0, 0.4, 0.75, 1]
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

    private func buildFields() {
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passField.translatesAutoresizingMaskIntoConstraints  = false
        card.addSubview(emailField)
        card.addSubview(passField)

        let img = UIImage(systemName: "eye.slash.fill")?.withRenderingMode(.alwaysTemplate)
        eyeBtn.setImage(img, for: .normal)
        eyeBtn.tintColor = DS.textDim
        eyeBtn.translatesAutoresizingMaskIntoConstraints = false
        eyeBtn.addTarget(self, action: #selector(togglePass), for: .touchUpInside)
        card.addSubview(eyeBtn)
    }

    private func buildLoginBtn() {
        loginBtn.translatesAutoresizingMaskIntoConstraints = false
        loginBtn.setTitle("Войти", for: .normal)
        loginBtn.setTitleColor(.white, for: .normal)
        loginBtn.titleLabel?.font = .app(18, .black)

        loginBtn.addTarget(self, action: #selector(loginTap), for: .touchUpInside)
        loginBtn.addTarget(self, action: #selector(pressDown), for: [.touchDown, .touchDragEnter])
        loginBtn.addTarget(self, action: #selector(pressUp),
                           for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        card.addSubview(loginBtn)

        spinner.color = .white
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        loginBtn.addSubview(spinner)
    }

    private func buildBottomLinks() {
        divider.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(divider)

        registerBtn.translatesAutoresizingMaskIntoConstraints = false
        registerBtn.setTitle("Создать аккаунт", for: .normal)
        registerBtn.setTitleColor(.white, for: .normal)
        registerBtn.titleLabel?.font = .app(16, .bold)
        registerBtn.layer.cornerRadius = 26
        registerBtn.layer.cornerCurve  = .continuous
        registerBtn.layer.borderWidth  = 1.5
        registerBtn.layer.borderColor  = DS.glassBdr.cgColor
        registerBtn.backgroundColor    = UIColor.white.withAlphaComponent(0.07)
        registerBtn.addTarget(self, action: #selector(registerTap), for: .touchUpInside)
        card.addSubview(registerBtn)

        forgotBtn.translatesAutoresizingMaskIntoConstraints = false
        forgotBtn.setTitle("Забыли пароль?", for: .normal)
        forgotBtn.setTitleColor(DS.textDim, for: .normal)
        forgotBtn.titleLabel?.font = .app(14, .semibold)
        forgotBtn.addTarget(self, action: #selector(forgotTap), for: .touchUpInside)
        card.addSubview(forgotBtn)
    }

    private func buildFeedback() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.font = .app(13, .semibold)
        errorLabel.textColor = UIColor(red: 1, green: 0.55, blue: 0.55, alpha: 1)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        card.addSubview(errorLabel)
    }


    private func buildConstraints() {
        NSLayoutConstraint.activate([
            logoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            logoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            logoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            taglineLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 10),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            card.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 32),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            cardBlur.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cardBlur.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            cardBlur.topAnchor.constraint(equalTo: card.topAnchor),
            cardBlur.bottomAnchor.constraint(equalTo: card.bottomAnchor),

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

            forgotBtn.topAnchor.constraint(equalTo: passField.bottomAnchor, constant: 10),
            forgotBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            loginBtn.topAnchor.constraint(equalTo: forgotBtn.bottomAnchor, constant: 22),
            loginBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            loginBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            loginBtn.heightAnchor.constraint(equalToConstant: 52),

            spinner.centerXAnchor.constraint(equalTo: loginBtn.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loginBtn.centerYAnchor),

            errorLabel.topAnchor.constraint(equalTo: loginBtn.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            divider.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 14),
            divider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            registerBtn.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            registerBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            registerBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            registerBtn.heightAnchor.constraint(equalToConstant: 52),
            registerBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28),
        ])
    }


    @objc private func loginTap() {
        output?.didTapLogin(email: emailField.value, password: passField.value)
    }

    @objc private func forgotTap()    { output?.didTapForgotPassword() }
    @objc private func registerTap()  { output?.didTapRegister() }

    @objc private func togglePass() {
        passField.toggleSecure()
        let showing = !passField.isSecure
        let name = showing ? "eye.fill" : "eye.slash.fill"
        eyeBtn.setImage(UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate), for: .normal)
    }

    @objc private func pressDown() {
        UIView.animate(withDuration: 0.12, delay: 0,
                       options: [.allowUserInteraction, .curveEaseOut]) {
            self.loginBtn.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func pressUp() {
        UIView.animate(withDuration: 0.22, delay: 0,
                       usingSpringWithDamping: 0.55, initialSpringVelocity: 8,
                       options: [.allowUserInteraction]) {
            self.loginBtn.transform = .identity
        }
    }
}


// MARK: - LoginViewController Extension
extension LoginViewController: LoginViewInput {
    func setLoading(_ isLoading: Bool) {
        loginBtn.isEnabled    = !isLoading
        forgotBtn.isEnabled   = !isLoading
        registerBtn.isEnabled = !isLoading
        loginBtn.setTitle(isLoading ? "" : "Войти", for: .normal)
        isLoading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    func showMessage(_ message: String) {
        errorLabel.text   = message
        errorLabel.isHidden = message.isEmpty
        guard !message.isEmpty else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.45
        anim.values = [0, -10, 10, -8, 8, -4, 4, 0]
        card.layer.add(anim, forKey: "shake")
    }
}

