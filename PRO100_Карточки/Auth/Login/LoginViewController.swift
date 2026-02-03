//
//  LoginViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol LoginViewInput: AnyObject {
    func showInDevelopmentAlert()
}

protocol LoginViewOutput: AnyObject {
    func viewDidLoad()
    func didTapLogin()
    func didTapForgotPassword()
    func didTapRegister()
}

final class LoginViewController: UIViewController {
    var output: LoginViewOutput?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logoLabel = UILabel()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let showPasswordButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)
    private let forgotPasswordButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Вход"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        logoLabel.text = "МозгоЁмка"
        logoLabel.font = .systemFont(ofSize: 28, weight: .bold)
        logoLabel.textAlignment = .center
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoLabel)

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

        showPasswordButton.setTitle("Показать", for: .normal)
        showPasswordButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(showPasswordButton)

        loginButton.setTitle("Войти", for: .normal)
        loginButton.backgroundColor = AppConstants.accentColor
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loginButton)

        forgotPasswordButton.setTitle("Забыли пароль?", for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotTapped), for: .touchUpInside)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(forgotPasswordButton)

        registerButton.setTitle("Нет аккаунта? Зарегистрироваться", for: .normal)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(registerButton)

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

            logoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 48),
            logoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            logoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            emailField.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 40),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 44),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -8),
            passwordField.heightAnchor.constraint(equalToConstant: 44),

            showPasswordButton.centerYAnchor.constraint(equalTo: passwordField.centerYAnchor),
            showPasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 48),

            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            registerButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 24),
            registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    @objc private func togglePassword() {
        passwordField.isSecureTextEntry.toggle()
        showPasswordButton.setTitle(passwordField.isSecureTextEntry ? "Показать" : "Скрыть", for: .normal)
    }

    @objc private func loginTapped() {
        output?.didTapLogin()
    }

    @objc private func forgotTapped() {
        output?.didTapForgotPassword()
    }

    @objc private func registerTapped() {
        output?.didTapRegister()
    }
}

extension LoginViewController: LoginViewInput {
    func showInDevelopmentAlert() {
        let alert = UIAlertController(title: nil, message: "Функция в разработке", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
