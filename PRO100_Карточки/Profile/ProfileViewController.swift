//
//  ProfileViewController.swift
//  PRO100_Карточки
//

import UIKit

protocol ProfileViewInput: AnyObject {
    func showInDevelopmentAlert()
    func showLogoutConfirm(onConfirm: @escaping () -> Void)
    func configure(profile: UserProfileModel)
}

protocol ProfileViewOutput: AnyObject {
    func viewDidLoad()
    func didTapEditProfile()
    func didTapLogout()
}

final class ProfileViewController: UIViewController {
    var output: ProfileViewOutput?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let avatarView = UIView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let statsStack = UIStackView()
    private let setsCountLabel = UILabel()
    private let cardsCountLabel = UILabel()
    private let progressLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Профиль"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        avatarView.backgroundColor = .tertiarySystemFill
        avatarView.layer.cornerRadius = 50
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarView)

        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        emailLabel.font = .systemFont(ofSize: 15)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)

        statsStack.axis = .vertical
        statsStack.spacing = 12
        statsStack.alignment = .leading
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statsStack)
        setsCountLabel.font = .systemFont(ofSize: 15)
        cardsCountLabel.font = .systemFont(ofSize: 15)
        progressLabel.font = .systemFont(ofSize: 15)
        for l in [setsCountLabel, cardsCountLabel, progressLabel] {
            l.textColor = .secondaryLabel
            statsStack.addArrangedSubview(l)
        }

        editButton.setTitle("Редактировать профиль", for: .normal)
        editButton.backgroundColor = AppConstants.accentColor
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.cornerRadius = 10
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(editButton)

        logoutButton.setTitle("Выйти", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoutButton)

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

            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            statsStack.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24),
            statsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            editButton.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 24),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            editButton.heightAnchor.constraint(equalToConstant: 48),

            logoutButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 24),
            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    @objc private func editTapped() { output?.didTapEditProfile() }
    @objc private func logoutTapped() { output?.didTapLogout() }
}

extension ProfileViewController: ProfileViewInput {
    func showInDevelopmentAlert() {
        let alert = UIAlertController(title: nil, message: "Функция в разработке", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func showLogoutConfirm(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: "Выйти?", message: "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in onConfirm() })
        present(alert, animated: true)
    }

    func configure(profile: UserProfileModel) {
        nameLabel.text = profile.name
        emailLabel.text = profile.email
        setsCountLabel.text = "Количество наборов: \(profile.setsCount)"
        cardsCountLabel.text = "Количество карточек: \(profile.cardsCount)"
        progressLabel.text = "Прогресс обучения: \(profile.learningProgress)%"
    }
}
