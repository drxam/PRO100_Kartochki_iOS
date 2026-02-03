//
//  RegisterViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol RegisterViewInput: AnyObject {}

protocol RegisterViewOutput: AnyObject {
    func viewDidLoad()
    func didTapRegister()
    func didTapLogin()
}

final class RegisterViewController: UIViewController, RegisterViewInput {
    var output: RegisterViewOutput?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let confirmPasswordField = UITextField()
    private let registerButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Регистрация"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        titleLabel.text = "Регистрация"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        emailField.placeholder = "Email"
        emailField.borderStyle = .roundedRect
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailField)

        passwordField.placeholder = "Пароль"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordField)

        confirmPasswordField.placeholder = "Подтверждение пароля"
        confirmPasswordField.borderStyle = .roundedRect
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(confirmPasswordField)

        registerButton.setTitle("Зарегистрироваться", for: .normal)
        registerButton.backgroundColor = AppConstants.accentColor
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 10
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(registerButton)

        loginButton.setTitle("Уже есть аккаунт? Войти", for: .normal)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loginButton)

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

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            confirmPasswordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            confirmPasswordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 44),

            registerButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 24),
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 48),

            loginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 24),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    @objc private func registerTapped() {
        output?.didTapRegister()
    }

    @objc private func loginTapped() {
        output?.didTapLogin()
    }
}
