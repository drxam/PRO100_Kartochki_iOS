//
//  APIConfig.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - APIConfig
enum APIConfig {
    static var baseURL: URL = URL(string: "http://localhost:8080/api")!

    static var siteOrigin: URL {
        baseURL.deletingLastPathComponent()
    }
}
