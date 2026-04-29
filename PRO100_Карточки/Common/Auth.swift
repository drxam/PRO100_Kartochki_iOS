//
//  Auth.swift
//  PRO100_Карточки
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case emailNotFound
    case serverUnavailable
    case validationError(String)
    case unauthorized
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Неверный email или пароль."
        case .emailAlreadyExists:
            return "Этот email уже занят."
        case .emailNotFound:
            return "Пользователь с таким email не найден."
        case .serverUnavailable:
            return "Проблема подключения к серверу. Попробуйте позже."
        case .validationError(let message):
            return message
        case .unauthorized:
            return "Сессия истекла. Войдите снова."
        case .unknown(let message):
            return message
        }
    }
}

final class AuthStorage {
    static let shared = AuthStorage()
    private let accessTokenKey = "auth_access_token"
    private let refreshTokenKey = "auth_refresh_token"

    var isAuthorized: Bool {
        accessToken != nil
    }

    var accessToken: String? {
        UserDefaults.standard.string(forKey: accessTokenKey)
    }

    var refreshToken: String? {
        UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    func saveTokens(access: String, refresh: String) {
        UserDefaults.standard.set(access, forKey: accessTokenKey)
        UserDefaults.standard.set(refresh, forKey: refreshTokenKey)
    }

    func saveAccessToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: accessTokenKey)
    }

    func clearToken() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}

final class AuthService {
    static let shared = AuthService()
    private let session = URLSession.shared
    private let baseURL = APIConfig.baseURL

    private func makeURL(path: String) -> URL {
        var u = baseURL
        for part in path.split(separator: "/") where !part.isEmpty {
            u = u.appendingPathComponent(String(part))
        }
        return u
    }

    func login(email: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        let body = ["email": email, "password": password]
        request(path: "/auth/login", method: "POST", body: body, authorized: false) { (result: Result<TokenPairResponse, AuthError>) in
            switch result {
            case .success(let tokens):
                AuthStorage.shared.saveTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
                completion(.success(tokens.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<String?, AuthError>) -> Void) {
        let body = ["email": email, "password": password]
        request(path: "/auth/register", method: "POST", body: body, authorized: false) { (result: Result<OptionalTokenPairResponse, AuthError>) in
            switch result {
            case .success(let response):
                if let access = response.accessToken, let refresh = response.refreshToken {
                    AuthStorage.shared.saveTokens(access: access, refresh: refresh)
                    completion(.success(access))
                } else {
                    completion(.success(nil))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func requestPasswordReset(email: String, completion: @escaping (Result<Void, AuthError>) -> Void) {
        let body = ["email": email]
        request(path: "/auth/forgot-password", method: "POST", body: body, authorized: false) { (result: Result<EmptyResponse, AuthError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Пара новых access/refresh с `POST /api/auth/refresh` (без `Authorization` — в теле `refresh_token`).
    func refreshTokens(completion: @escaping (Result<Void, AuthError>) -> Void) {
        guard let refresh = AuthStorage.shared.refreshToken, !refresh.isEmpty else {
            completion(.failure(.unauthorized))
            return
        }
        let body = ["refresh_token": refresh]
        request(path: "/auth/refresh", method: "POST", body: body, authorized: false) { (result: Result<TokenPairResponse, AuthError>) in
            switch result {
            case .success(let tokens):
                AuthStorage.shared.saveTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, AuthError>) -> Void) {
        let refresh = AuthStorage.shared.refreshToken ?? ""
        let body = ["refresh_token": refresh]
        request(path: "/auth/logout", method: "POST", body: body, authorized: true) { (result: Result<EmptyResponse, AuthError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func request<T: Decodable, B: Encodable>(
        path: String,
        method: String,
        body: B?,
        authorized: Bool,
        completion: @escaping (Result<T, AuthError>) -> Void
    ) {
        let clean = path.hasPrefix("/") ? String(path.dropFirst()) : path
        var request = URLRequest(url: makeURL(path: clean))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if authorized, let token = AuthStorage.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(.failure(.serverUnavailable))
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    completion(.failure(.serverUnavailable))
                    return
                }
                let payload = data ?? Data()
                if (200...299).contains(http.statusCode) {
                    if T.self == EmptyResponse.self {
                        completion(.success(EmptyResponse() as! T))
                        return
                    }
                    guard let decoded = try? JSONDecoder().decode(T.self, from: payload) else {
                        completion(.failure(.unknown("Некорректный ответ сервера.")))
                        return
                    }
                    completion(.success(decoded))
                    return
                }

                if let envelope = try? JSONDecoder().decode(APIErrorEnvelope.self, from: payload) {
                    switch http.statusCode {
                    case 400:
                        completion(.failure(.validationError(envelope.error.message)))
                    case 401:
                        completion(.failure(.unauthorized))
                    case 404:
                        completion(.failure(.emailNotFound))
                    case 409:
                        completion(.failure(.emailAlreadyExists))
                    default:
                        completion(.failure(.unknown(envelope.error.message)))
                    }
                    return
                }

                completion(.failure(.unknown("Ошибка сервера: \(http.statusCode)")))
            }
        }.resume()
    }
}

struct APIErrorEnvelope: Decodable {
    struct APIErrorPayload: Decodable {
        let code: String
        let message: String
    }
    let error: APIErrorPayload
}

struct TokenPairResponse: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct OptionalTokenPairResponse: Decodable {
    let accessToken: String?
    let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct EmptyResponse: Decodable {
    init() {}
}
