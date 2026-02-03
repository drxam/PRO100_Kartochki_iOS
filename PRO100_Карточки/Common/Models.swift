//
//  Models.swift
//  PRO100_Карточки
//

import Foundation

struct CardSetModel {
    let id: String
    let title: String
    let description: String
    let cardCount: Int
    let category: String
    let isPrivate: Bool
    let cards: [CardModel]
}

struct CardModel {
    let id: String
    let question: String
    let answer: String
    let setId: String
    let setTitle: String
    let category: String
    let tags: [String]
}

struct PublicSetModel {
    let id: String
    let title: String
    let cardCount: Int
    let category: String
    let authorName: String
    let authorAvatarPlaceholder: Bool
}

struct UserProfileModel {
    let name: String
    let email: String
    let setsCount: Int
    let cardsCount: Int
    let learningProgress: Int // 0-100
}
