//
//  ProfileEditViewController.swift
//  PRO100_Карточки
//

import UIKit
import PhotosUI

// MARK: - ProfileEditViewController
final class ProfileEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var profile: UserProfileModel
    private let avatarView = UIImageView()
    private let cameraButton = UIButton(type: .system)
    private let nameField = UITextField()
    private let emailLabel = UILabel()
    private let activity = UIActivityIndicatorView(style: .medium)
    private var selectedAvatarData: Data?
    private var selectedAvatarImage: UIImage?

    init(profile: UserProfileModel) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Редактирование профиля"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTapped))
        setupUI()
    }

    private func setupUI() {
        avatarView.backgroundColor = .tertiarySystemFill
        avatarView.layer.cornerRadius = 50
        avatarView.clipsToBounds = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        cameraButton.backgroundColor = .systemBackground
        cameraButton.layer.cornerRadius = 16
        cameraButton.addTarget(self, action: #selector(changeAvatarTapped), for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false

        nameField.borderStyle = .roundedRect
        nameField.placeholder = "Имя"
        nameField.text = profile.name
        nameField.translatesAutoresizingMaskIntoConstraints = false

        emailLabel.text = "Email: \(profile.email)"
        emailLabel.textColor = .secondaryLabel
        emailLabel.translatesAutoresizingMaskIntoConstraints = false

        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false

        [avatarView, cameraButton, nameField, emailLabel, activity].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            avatarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            cameraButton.widthAnchor.constraint(equalToConstant: 32),
            cameraButton.heightAnchor.constraint(equalToConstant: 32),
            cameraButton.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 4),
            cameraButton.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 4),
            nameField.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 24),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emailLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            activity.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func changeAvatarTapped() {
        let alert = UIAlertController(title: "Аватар", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { _ in self.pickImage(source: .photoLibrary) }))
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: { _ in self.pickImage(source: .camera) }))
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    private func pickImage(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage,
           let data = prepareAvatarData(from: image) {
            avatarView.image = image
            selectedAvatarImage = image
            selectedAvatarData = data
        } else {
            showTopBanner("Не удалось подготовить изображение. Попробуйте другое фото.")
        }
        dismiss(animated: true)
    }

    private func prepareAvatarData(from image: UIImage) -> Data? {
        let maxSide: CGFloat = 1280
        let size = image.size
        let largestSide = max(size.width, size.height)
        let scale = largestSide > maxSide ? (maxSide / largestSide) : 1
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let normalized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        let maxBytes = 5 * 1024 * 1024
        let qualities: [CGFloat] = [0.85, 0.75, 0.65, 0.55]
        for quality in qualities {
            if let data = normalized.jpegData(compressionQuality: quality), data.count <= maxBytes {
                return data
            }
        }
        return nil
    }

    @objc private func saveTapped() {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            showTopBanner("Имя не может быть пустым.")
            return
        }
        activity.startAnimating()
        UserService.shared.updateMe(name: name) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                if let avatarData = self.selectedAvatarData {
                    self.uploadAvatarWithFallback(jpegData: avatarData) { uploadResult in
                        self.activity.stopAnimating()
                        switch uploadResult {
                        case .success:
                            self.showToast("Профиль обновлен")
                            self.navigationController?.popViewController(animated: true)
                        case .failure(let error):
                            self.showTopBanner(error.localizedDescription)
                        }
                    }
                } else {
                    self.activity.stopAnimating()
                    self.showToast("Профиль обновлен")
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self.activity.stopAnimating()
                self.showTopBanner(error.localizedDescription)
            }
        }
    }

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func uploadAvatarWithFallback(jpegData: Data, completion: @escaping (Result<Void, AuthError>) -> Void) {
        UserService.shared.uploadAvatar(
            imageData: jpegData,
            filename: "avatar.jpg",
            mimeType: "image/jpeg"
        ) { [weak self] first in
            guard let self else { return }
            switch first {
            case .success:
                completion(.success(()))
            case .failure:
                guard let pngData = self.selectedAvatarImage?.pngData(),
                      pngData.count <= 5 * 1024 * 1024 else {
                    completion(first)
                    return
                }
                UserService.shared.uploadAvatar(
                    imageData: pngData,
                    filename: "avatar.png",
                    mimeType: "image/png",
                    completion: completion
                )
            }
        }
    }
}
