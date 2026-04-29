//
//  Pro100APIClient.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - Pro100APIClient
enum Pro100APIClient {
    static let session: URLSession = .shared

    static var jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    static var jsonEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    static func get(path: String, query: [String: String] = [:], authorized: Bool) -> URLRequest {
        request(path: path, method: "GET", query: query, body: nil as Data?, authorized: authorized)
    }

    static func postJSON(path: String, query: [String: String] = [:], body: some Encodable, authorized: Bool) throws -> URLRequest {
        var req = request(path: path, method: "POST", query: query, body: try jsonEncoder.encode(body), authorized: authorized)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }

    static func putJSON(path: String, query: [String: String] = [:], body: some Encodable, authorized: Bool) throws -> URLRequest {
        var req = request(path: path, method: "PUT", query: query, body: try jsonEncoder.encode(body), authorized: authorized)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return req
    }

    static func delete(path: String, query: [String: String] = [:], authorized: Bool) -> URLRequest {
        request(path: path, method: "DELETE", query: query, body: nil as Data?, authorized: authorized)
    }

    private static func request(path: String, method: String, query: [String: String], body: Data?, authorized: Bool) -> URLRequest {
        var base = APIConfig.baseURL
        for component in path.split(separator: "/") where !component.isEmpty {
            base = base.appendingPathComponent(String(component))
        }
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        let url = components?.url ?? base
        var req = URLRequest(url: url)
        req.httpMethod = method
        if authorized, let token = AuthStorage.shared.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = body
        return req
    }

    static func dataTask(_ request: URLRequest, completion: @escaping (Result<(HTTPURLResponse, Data), AuthError>) -> Void) {
        dataTaskWithOptionalRefresh(request, alreadyRefreshed: false, completion: completion)
    }

    private static func dataTaskWithOptionalRefresh(
        _ request: URLRequest,
        alreadyRefreshed: Bool,
        completion: @escaping (Result<(HTTPURLResponse, Data), AuthError>) -> Void
    ) {
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
                let hadBearer = !(request.value(forHTTPHeaderField: "Authorization") ?? "").isEmpty
                if http.statusCode == 401, hadBearer, !alreadyRefreshed, AuthStorage.shared.refreshToken != nil {
                    AuthService.shared.refreshTokens { result in
                        switch result {
                        case .failure:
                            completion(.failure(.unauthorized))
                        case .success:
                            var retried = request
                            if let t = AuthStorage.shared.accessToken {
                                retried.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
                            } else {
                                retried.setValue(nil, forHTTPHeaderField: "Authorization")
                            }
                            dataTaskWithOptionalRefresh(retried, alreadyRefreshed: true, completion: completion)
                        }
                    }
                    return
                }
                completion(.success((http, payload)))
            }
        }.resume()
    }

    static func parseError(_ data: Data, status: Int) -> AuthError {
        if let envelope = try? jsonDecoder.decode(APIErrorEnvelope.self, from: data) {
            if status == 401 { return .unauthorized }
            return .unknown(envelope.error.message)
        }
        return .unknown("Ошибка сервера: \(status)")
    }
}
