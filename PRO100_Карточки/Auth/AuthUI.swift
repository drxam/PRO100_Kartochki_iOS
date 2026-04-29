//
//  AuthUI.swift
//  PRO100_Карточки
//


import UIKit


// MARK: - GradientButton
final class GradientButton: UIButton {
    private let grad = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        grad.colors     = [DS.royal.cgColor, DS.crimson.cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(grad, at: 0)
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        grad.frame        = bounds
        layer.cornerRadius = bounds.height / 2
        grad.cornerRadius  = layer.cornerRadius
        CATransaction.commit()
    }
}


// MARK: - AuthFieldRow
final class AuthFieldRow: UIView {

    private let icon  = UIImageView()
    private let field = UITextField()

    var value: String { field.text ?? "" }
    var isSecure: Bool { field.isSecureTextEntry }

    init(icon iconName: String, placeholder: String, secure: Bool = false) {
        super.init(frame: .zero)
        backgroundColor = DS.field
        layer.cornerRadius = 18
        layer.cornerCurve  = .continuous
        layer.borderWidth  = 1
        layer.borderColor  = DS.fieldBdr.cgColor

        icon.image       = UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate)
        icon.tintColor   = DS.textDim
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        field.borderStyle            = .none
        field.backgroundColor        = .clear
        field.textColor              = .white
        field.tintColor              = .white
        field.font                   = .app(16, .semibold)
        field.autocapitalizationType = .none
        field.autocorrectionType     = .no
        field.isSecureTextEntry      = secure
        field.textContentType        = secure ? .password : .username
        field.keyboardType           = secure ? .default : .emailAddress
        field.keyboardAppearance     = .dark
        field.attributedPlaceholder  = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.38),
                .font: UIFont.app(16, .regular)
            ]
        )
        field.translatesAutoresizingMaskIntoConstraints = false

        addSubview(icon)
        addSubview(field)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            field.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            field.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            field.topAnchor.constraint(equalTo: topAnchor),
            field.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        field.addTarget(self, action: #selector(onBegin), for: .editingDidBegin)
        field.addTarget(self, action: #selector(onEnd),   for: .editingDidEnd)
    }

    required init?(coder: NSCoder) { fatalError() }

    func toggleSecure() { field.isSecureTextEntry.toggle() }

    func addEditingTarget(_ target: Any?, action: Selector, for events: UIControl.Event) {
        field.addTarget(target, action: action, for: events)
    }

    @objc private func onBegin() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor   = UIColor.white.withAlphaComponent(0.18)
            self.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        }
    }

    @objc private func onEnd() {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor   = DS.field
            self.layer.borderColor = DS.fieldBdr.cgColor
        }
    }
}


// MARK: - AuthDivider
final class AuthDivider: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let left = rule(); let right = rule()
        let label = UILabel()
        label.text      = "или"
        label.font      = .app(13, .medium)
        label.textColor = DS.textMuted
        label.translatesAutoresizingMaskIntoConstraints = false
        [left, label, right].forEach { addSubview($0) }
        NSLayoutConstraint.activate([
            left.leadingAnchor.constraint(equalTo: leadingAnchor),
            left.centerYAnchor.constraint(equalTo: centerYAnchor),
            left.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10),
            left.heightAnchor.constraint(equalToConstant: 1),

            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),

            right.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            right.centerYAnchor.constraint(equalTo: centerYAnchor),
            right.trailingAnchor.constraint(equalTo: trailingAnchor),
            right.heightAnchor.constraint(equalToConstant: 1),
            right.widthAnchor.constraint(equalTo: left.widthAnchor),

            heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    private func rule() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.16)
        return v
    }
}


func makeAuthCard() -> (card: UIView, blur: UIVisualEffectView) {
    let card = UIView()
    card.backgroundColor  = DS.glass
    card.layer.cornerRadius = 32
    card.layer.cornerCurve  = .continuous
    card.layer.shadowColor  = UIColor.black.cgColor
    card.layer.shadowOpacity = 0.55
    card.layer.shadowRadius  = 32
    card.layer.shadowOffset  = CGSize(width: 0, height: 16)

    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    blur.translatesAutoresizingMaskIntoConstraints = false
    blur.layer.cornerRadius = 32
    blur.layer.cornerCurve  = .continuous
    blur.clipsToBounds = true
    card.addSubview(blur)
    return (card, blur)
}


// MARK: - ValidationRow
final class ValidationRow: UIView {
    private let dot  = UILabel()
    private let text = UILabel()

    init(_ message: String) {
        super.init(frame: .zero)
        dot.text      = "●"
        dot.font      = .app(8, .regular)
        dot.textColor = DS.textMuted
        dot.translatesAutoresizingMaskIntoConstraints = false

        text.text      = message
        text.font      = .app(13, .medium)
        text.textColor = DS.textMuted
        text.translatesAutoresizingMaskIntoConstraints = false

        addSubview(dot)
        addSubview(text)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 16),

            text.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 4),
            text.trailingAnchor.constraint(equalTo: trailingAnchor),
            text.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func setValid(_ valid: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.dot.textColor  = valid ? DS.royal : DS.textMuted
            self.text.textColor = valid ? .white    : DS.textMuted
        }
    }
}
