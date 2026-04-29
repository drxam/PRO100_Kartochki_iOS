//
//  ProfileViewController.swift
//  PRO100_Карточки
//


import UIKit

// MARK: - ProfileViewInput
protocol ProfileViewInput: AnyObject {
    func showInDevelopmentAlert()
    func showLogoutConfirm(onConfirm: @escaping () -> Void)
    func configure(profile: UserProfileModel)
    func showError(_ message: String)
}

// MARK: - ProfileViewOutput
protocol ProfileViewOutput: AnyObject {
    func viewDidLoad()
    func didTapEditProfile()
    func didTapLogout()
}

// MARK: - ProfileViewController
final class ProfileViewController: UIViewController {
    var output: ProfileViewOutput?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let headerCard = UIView()
    private let avatarView = UIView()
    private let avatarInitialsLabel = UILabel()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let roleBadgeLabel = UILabel()
    private let dateLabel = UILabel()

    private let statsCard = UIView()
    private let setsCountLabel = UILabel()
    private let cardsCountLabel = UILabel()
    private let progressLabel = UILabel()

    private let actionsCard = UIView()
    private let editButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output?.viewDidLoad()
    }

    private func setupUI() {
        view.backgroundColor = DS.bgTop
        applyDarkNavBar()
        title = "Профиль"
        navigationController?.navigationBar.prefersLargeTitles = true

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 14

        setupHeaderCard()
        setupStatsCard()
        setupActionsCard()

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupHeaderCard() {
        styleCard(headerCard)
        stackView.addArrangedSubview(headerCard)

        let avatarGrad = CAGradientLayer()
        avatarGrad.colors = [DS.royal.cgColor, DS.crimson.cgColor]
        avatarGrad.startPoint = CGPoint(x: 0, y: 0)
        avatarGrad.endPoint   = CGPoint(x: 1, y: 1)
        avatarView.layer.insertSublayer(avatarGrad, at: 0)
        avatarView.layer.cornerRadius = 44
        avatarView.layer.cornerCurve  = .continuous
        avatarView.clipsToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        DispatchQueue.main.async {
            avatarGrad.frame = self.avatarView.bounds
        }

        headerCard.addSubview(avatarView)

        avatarInitialsLabel.font = .app(30, .black)
        avatarInitialsLabel.textColor = .white
        avatarInitialsLabel.textAlignment = .center
        avatarInitialsLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarInitialsLabel)

        nameLabel.font = .app(22, .black)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(nameLabel)

        emailLabel.font = .app(15, .medium)
        emailLabel.textColor = DS.textDim
        emailLabel.textAlignment = .center
        emailLabel.numberOfLines = 2
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(emailLabel)

        roleBadgeLabel.font = .app(12, .bold)
        roleBadgeLabel.textColor = .white
        roleBadgeLabel.backgroundColor = DS.royal.withAlphaComponent(0.7)
        roleBadgeLabel.layer.cornerRadius = 11
        roleBadgeLabel.layer.borderWidth = 1
        roleBadgeLabel.layer.borderColor = DS.royal.withAlphaComponent(0.5).cgColor
        roleBadgeLabel.clipsToBounds = true
        roleBadgeLabel.textAlignment = .center
        roleBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(roleBadgeLabel)

        dateLabel.font = .app(13, .medium)
        dateLabel.textColor = DS.textMuted
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 2
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 18),
            avatarView.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 88),
            avatarView.heightAnchor.constraint(equalToConstant: 88),

            avatarInitialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarInitialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),

            roleBadgeLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            roleBadgeLabel.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            roleBadgeLabel.heightAnchor.constraint(equalToConstant: 22),
            roleBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 90),

            dateLabel.topAnchor.constraint(equalTo: roleBadgeLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            dateLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -16)
        ])
    }

    private func setupStatsCard() {
        styleCard(statsCard)
        stackView.addArrangedSubview(statsCard)

        let titleLabel = sectionTitle("Статистика")
        statsCard.addSubview(titleLabel)

        setsCountLabel.font = .app(15, .semibold)
        cardsCountLabel.font = .app(15, .semibold)
        progressLabel.font = .app(15, .semibold)
        progressLabel.numberOfLines = 0

        for label in [setsCountLabel, cardsCountLabel, progressLabel] {
            label.textColor = DS.textDim
            label.translatesAutoresizingMaskIntoConstraints = false
            statsCard.addSubview(label)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -14),

            setsCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            setsCountLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 14),
            setsCountLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -14),

            cardsCountLabel.topAnchor.constraint(equalTo: setsCountLabel.bottomAnchor, constant: 8),
            cardsCountLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 14),
            cardsCountLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -14),

            progressLabel.topAnchor.constraint(equalTo: cardsCountLabel.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 14),
            progressLabel.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -14),
            progressLabel.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -14)
        ])
    }

    private func setupActionsCard() {
        styleCard(actionsCard)
        stackView.addArrangedSubview(actionsCard)

        let titleLabel = sectionTitle("Действия")
        actionsCard.addSubview(titleLabel)

        let editGradBtn = GradientButton()
        editGradBtn.setTitle("Редактировать профиль", for: .normal)
        editGradBtn.setTitleColor(.white, for: .normal)
        editGradBtn.titleLabel?.font = .app(16, .bold)
        editGradBtn.layer.shadowColor   = DS.royal.cgColor
        editGradBtn.layer.shadowOpacity = 0.4
        editGradBtn.layer.shadowRadius  = 14
        editGradBtn.layer.shadowOffset  = CGSize(width: 0, height: 6)
        editGradBtn.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        editGradBtn.translatesAutoresizingMaskIntoConstraints = false
        actionsCard.addSubview(editGradBtn)
        editButton.removeFromSuperview()
        actionsCard.addSubview(editButton)
        editButton.isHidden = true

        logoutButton.setTitle("Выйти из аккаунта", for: .normal)
        logoutButton.setTitleColor(DS.crimson, for: .normal)
        logoutButton.titleLabel?.font = .app(16, .bold)
        logoutButton.layer.cornerRadius = 22
        logoutButton.layer.cornerCurve  = .continuous
        logoutButton.layer.borderWidth  = 1.5
        logoutButton.layer.borderColor  = DS.crimson.withAlphaComponent(0.5).cgColor
        logoutButton.backgroundColor    = DS.crimson.withAlphaComponent(0.08)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        actionsCard.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: actionsCard.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: actionsCard.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: actionsCard.trailingAnchor, constant: -14),

            editGradBtn.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            editGradBtn.leadingAnchor.constraint(equalTo: actionsCard.leadingAnchor, constant: 14),
            editGradBtn.trailingAnchor.constraint(equalTo: actionsCard.trailingAnchor, constant: -14),
            editGradBtn.heightAnchor.constraint(equalToConstant: 50),

            logoutButton.topAnchor.constraint(equalTo: editGradBtn.bottomAnchor, constant: 10),
            logoutButton.leadingAnchor.constraint(equalTo: actionsCard.leadingAnchor, constant: 14),
            logoutButton.trailingAnchor.constraint(equalTo: actionsCard.trailingAnchor, constant: -14),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.bottomAnchor.constraint(equalTo: actionsCard.bottomAnchor, constant: -14),
        ])
        return
    }

    private func styleCard(_ view: UIView) {
        view.backgroundColor    = DS.glass
        view.layer.cornerRadius = 22
        view.layer.cornerCurve  = .continuous
        view.layer.borderWidth  = 1
        view.layer.borderColor  = DS.glassBdr.cgColor
        view.layer.shadowColor  = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.35
        view.layer.shadowRadius  = 18
        view.layer.shadowOffset  = CGSize(width: 0, height: 8)
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .app(15, .bold)
        label.textColor = DS.textDim
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    @objc private func editTapped() {
        output?.didTapEditProfile()
    }

    @objc private func logoutTapped() {
        output?.didTapLogout()
    }
}

// MARK: - ProfileViewController Extension
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
        let trimmedName = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmedName.isEmpty ? "Без имени" : profile.name

        nameLabel.text = displayName
        avatarInitialsLabel.text = String(displayName.prefix(1)).uppercased()
        emailLabel.text = profile.email
        roleBadgeLabel.text = "  \(profile.role)  "
        dateLabel.text = "Дата регистрации: \(profile.registeredAt)"

        setsCountLabel.text = "Наборов: \(profile.setsCount)"
        cardsCountLabel.text = "Карточек: \(profile.cardsCount)"
        progressLabel.text = "Прогресс обучения: \(profile.learningProgress)%"
    }

    func showError(_ message: String) {
        showTopBanner(message)
    }
}
