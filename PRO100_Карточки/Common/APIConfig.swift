//
//  APIConfig.swift
//  PRO100_Карточки
//

import Foundation

enum APIConfig {
    /// База REST API, совпадает с `@BasePath` в `cmd/api/main.go`.
    static var baseURL: URL = URL(string: "http://localhost:8080/api")!

    /// Хост без `/api` — для относительных путей вроде `/uploads/...` из `avatar_url`.
    static var siteOrigin: URL {
        baseURL.deletingLastPathComponent()
    }
}
