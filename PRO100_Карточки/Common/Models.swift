//
//  Models.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - CardSetModel
struct CardSetModel {
    let id: String
    let title: String
    let description: String
    let cardCount: Int
    let category: String
    let tags: [String]
    let isPrivate: Bool
    let cards: [CardModel]
}

// MARK: - CardModel
struct CardModel {
    let id: String
    let question: String
    let answer: String
    let setId: String
    let setTitle: String
    let category: String
    let tags: [String]
}

// MARK: - PublicSetModel
struct PublicSetModel {
    let id: String
    let title: String
    let cardCount: Int
    let category: String
    let authorName: String
    let authorAvatarURL: String?
    let popularity: Int
    let createdAt: Date
}

// MARK: - UserProfileModel
struct UserProfileModel {
    let name: String
    let email: String
    let role: String
    let registeredAt: String
    let setsCount: Int
    let cardsCount: Int
    let learningProgress: Int
}
