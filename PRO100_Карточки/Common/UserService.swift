//
//  UserService.swift
//  PRO100_Карточки
//

import Foundation

// MARK: - UserService
final class UserService {
    static let shared = UserService()

    private let baseURL = APIConfig.baseURL

    private func makeURL(path: String) -> URL {
        var u = baseURL
        for part in path.split(separator: "/") where !part.isEmpty {
            u = u.appendingPathComponent(String(part))
        }
        return u
    }

    func fetchMe(completion: @escaping (Result<UserProfileModel, AuthError>) -> Void) {
        var request = URLRequest(url: makeURL(path: "users/me"))
        request.httpMethod = "GET"
        authorize(&request)

        Pro100APIClient.dataTask(request) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let payload)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(self.parseError(data: payload, status: http.statusCode)))
                    return
                }
                guard let dto = try? JSONDecoder().decode(MeResponse.self, from: payload) else {
                    completion(.failure(.unknown("Некорректный ответ профиля.")))
                    return
                }
                completion(.success(dto.toModel()))
            }
        }
    }

    func updateMe(name: String, completion: @escaping (Result<UserProfileModel, AuthError>) -> Void) {
        var request = URLRequest(url: makeURL(path: "users/me"))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authorize(&request)
        request.httpBody = try? JSONEncoder().encode(["username": name])

        Pro100APIClient.dataTask(request) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let payload)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(self.parseError(data: payload, status: http.statusCode)))
                    return
                }
                guard let dto = try? JSONDecoder().decode(UserResponse.self, from: payload) else {
                    completion(.failure(.unknown("Некорректный ответ профиля.")))
                    return
                }
                completion(.success(dto.toModel(learningProgress: LearningProgressStorage.displayPercent())))
            }
        }
    }

    func uploadAvatar(
        imageData: Data,
        filename: String = "avatar.jpg",
        mimeType: String = "image/jpeg",
        completion: @escaping (Result<Void, AuthError>) -> Void
    ) {
        var request = URLRequest(url: makeURL(path: "users/me/avatar"))
        request.httpMethod = "POST"
        authorize(&request)

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        Pro100APIClient.dataTask(request) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let payload)):
                if (200...299).contains(http.statusCode) {
                    completion(.success(()))
                } else {
                    completion(.failure(self.parseError(data: payload, status: http.statusCode)))
                }
            }
        }
    }

    private func authorize(_ request: inout URLRequest) {
        if let token = AuthStorage.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    private func parseError(data: Data, status: Int) -> AuthError {
        if let envelope = try? JSONDecoder().decode(APIErrorEnvelope.self, from: data) {
            if status == 401 { return .unauthorized }
            return .unknown(envelope.error.message)
        }
        if let legacy = try? JSONDecoder().decode(LegacyErrorResponse.self, from: data),
           let message = legacy.error?.trimmingCharacters(in: .whitespacesAndNewlines),
           !message.isEmpty {
            if status == 401 { return .unauthorized }
            return .unknown(message)
        }
        return .unknown("Ошибка профиля: \(status)")
    }
}

private struct LegacyErrorResponse: Decodable {
    let error: String?
}

private struct MeResponse: Decodable {
    let email: String
    let username: String?
    let role: String?
    let createdAt: String?
    let stats: Stats?

    enum CodingKeys: String, CodingKey {
        case email, username, role, stats
        case createdAt = "created_at"
    }

    struct Stats: Decodable {
        let cardsCount: Int?
        let decksCount: Int?

        enum CodingKeys: String, CodingKey {
            case cardsCount = "cards_count"
            case decksCount = "decks_count"
        }
    }

    func toModel() -> UserProfileModel {
        UserProfileModel(
            name: (username?.isEmpty == false ? username! : email),
            email: email,
            role: role ?? "Пользователь",
            registeredAt: formatDate(createdAt),
            setsCount: stats?.decksCount ?? 0,
            cardsCount: stats?.cardsCount ?? 0,
            learningProgress: LearningProgressStorage.displayPercent()
        )
    }

    private func formatDate(_ raw: String?) -> String {
        guard let raw else { return "-" }
        let iso = ISO8601DateFormatter()
        guard let date = iso.date(from: raw) else { return raw }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

private struct UserResponse: Decodable {
    let email: String
    let username: String?
    let role: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case email, username, role
        case createdAt = "created_at"
    }

    func toModel(learningProgress: Int) -> UserProfileModel {
        UserProfileModel(
            name: (username?.isEmpty == false ? username! : email),
            email: email,
            role: role ?? "Пользователь",
            registeredAt: createdAt ?? "-",
            setsCount: 0,
            cardsCount: 0,
            learningProgress: learningProgress
        )
    }
}
