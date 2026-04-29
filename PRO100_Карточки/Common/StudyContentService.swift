//
//  StudyContentService.swift
//  PRO100_Карточки
//


import Foundation

// MARK: - StudyContentService
final class StudyContentService {
    static let shared = StudyContentService()

    private init() {}


    func fetchCategories(completion: @escaping (Result<[APICategory], AuthError>) -> Void) {
        let req = Pro100APIClient.get(path: "categories", authorized: false)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let list = Self.decodeCategoriesList(data) else {
                    completion(.failure(.unknown("Некорректный ответ категорий.")))
                    return
                }
                completion(.success(list))
            }
        }
    }

    func fetchTags(search: String? = nil, completion: @escaping (Result<[APITag], AuthError>) -> Void) {
        var q: [String: String] = [:]
        if let s = search?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty {
            q["search"] = s
        }
        let req = Pro100APIClient.get(path: "tags", query: q, authorized: false)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let list = Self.decodeTagsList(data) else {
                    completion(.failure(.unknown("Некорректный ответ тегов.")))
                    return
                }
                completion(.success(list))
            }
        }
    }

    func createCategory(name: String, completion: @escaping (Result<APICategory, AuthError>) -> Void) {
        do {
            let req = try Pro100APIClient.postJSON(path: "categories", body: CreateNamedBody(name: name), authorized: true)
            Pro100APIClient.dataTask(req) { result in
                switch result {
                case .failure(let e):
                    completion(.failure(e))
                case .success((let http, let data)):
                    guard (200...299).contains(http.statusCode) else {
                        completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                        return
                    }
                    guard let cat = try? Pro100APIClient.jsonDecoder.decode(APICategory.self, from: data) else {
                        completion(.failure(.unknown("Не удалось создать категорию.")))
                        return
                    }
                    completion(.success(cat))
                }
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }

    func createTag(name: String, completion: @escaping (Result<APITag, AuthError>) -> Void) {
        do {
            let req = try Pro100APIClient.postJSON(path: "tags", body: CreateNamedBody(name: name), authorized: true)
            Pro100APIClient.dataTask(req) { result in
                switch result {
                case .failure(let e):
                    completion(.failure(e))
                case .success((let http, let data)):
                    guard (200...299).contains(http.statusCode) else {
                        completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                        return
                    }
                    guard let tag = try? Pro100APIClient.jsonDecoder.decode(APITag.self, from: data) else {
                        completion(.failure(.unknown("Не удалось создать тег.")))
                        return
                    }
                    completion(.success(tag))
                }
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }


    func listMyDecks(
        page: Int,
        limit: Int = 20,
        search: String? = nil,
        categoryId: Int? = nil,
        completion: @escaping (Result<DecksListResponse, AuthError>) -> Void
    ) {
        var q: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        if let s = search, !s.isEmpty { q["search"] = s }
        if let c = categoryId { q["category_id"] = "\(c)" }
        let req = Pro100APIClient.get(path: "decks", query: q, authorized: true)
        Pro100APIClient.dataTask(req) { result in
            self.decodeDecksList(result, completion: completion)
        }
    }

    func getMyDeck(id: Int, completion: @escaping (Result<DeckFullDTO, AuthError>) -> Void) {
        let req = Pro100APIClient.get(path: "decks/\(id)", authorized: true)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let deck = try? Pro100APIClient.jsonDecoder.decode(DeckFullDTO.self, from: data) else {
                    completion(.failure(.unknown("Некорректный ответ набора.")))
                    return
                }
                completion(.success(deck))
            }
        }
    }

    func createDeck(
        title: String,
        description: String?,
        isPublic: Bool,
        categoryId: Int?,
        tagIds: [Int],
        completion: @escaping (Result<DeckFullDTO, AuthError>) -> Void
    ) {
        let body = CreateDeckBody(
            title: title,
            description: description,
            categoryId: categoryId,
            isPublic: isPublic,
            tagIds: tagIds.isEmpty ? nil : tagIds
        )
        do {
            let req = try Pro100APIClient.postJSON(path: "decks", body: body, authorized: true)
            Pro100APIClient.dataTask(req) { result in
                self.decodeDeckFull(result, completion: completion)
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }

    func updateDeck(
        id: Int,
        title: String?,
        description: String?,
        isPublic: Bool?,
        categoryId: Int?,
        tagIds: [Int]?,
        completion: @escaping (Result<DeckFullDTO, AuthError>) -> Void
    ) {
        let body = UpdateDeckBody(
            title: title,
            description: description,
            categoryId: categoryId,
            isPublic: isPublic,
            tagIds: tagIds
        )
        do {
            let req = try Pro100APIClient.putJSON(path: "decks/\(id)", body: body, authorized: true)
            Pro100APIClient.dataTask(req) { result in
                self.decodeDeckFull(result, completion: completion)
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }

    func deleteDeck(id: Int, completion: @escaping (Result<Void, AuthError>) -> Void) {
        let req = Pro100APIClient.delete(path: "decks/\(id)", authorized: true)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                completion(.success(()))
            }
        }
    }


    func listPublicDecks(
        page: Int,
        limit: Int = 20,
        search: String? = nil,
        categoryId: Int? = nil,
        sortBy: String,
        completion: @escaping (Result<PublicDecksListResponse, AuthError>) -> Void
    ) {
        var q: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)",
            "sort_by": sortBy
        ]
        if let s = search, !s.isEmpty { q["search"] = s }
        if let c = categoryId { q["category_id"] = "\(c)" }
        let req = Pro100APIClient.get(path: "public/decks", query: q, authorized: false)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let decoded = try? Pro100APIClient.jsonDecoder.decode(PublicDecksListResponse.self, from: data) else {
                    completion(.failure(.unknown("Некорректный ответ публичных наборов.")))
                    return
                }
                completion(.success(decoded))
            }
        }
    }

    func getPublicDeck(id: Int, completion: @escaping (Result<PublicDeckDetailDTO, AuthError>) -> Void) {
        let req = Pro100APIClient.get(path: "public/decks/\(id)", authorized: false)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let deck = try? Pro100APIClient.jsonDecoder.decode(PublicDeckDetailDTO.self, from: data) else {
                    completion(.failure(.unknown("Некорректный ответ публичного набора.")))
                    return
                }
                completion(.success(deck))
            }
        }
    }

    func copyPublicDeck(id: Int, completion: @escaping (Result<Void, AuthError>) -> Void) {
        do {
            let req = try Pro100APIClient.postJSON(path: "public/decks/\(id)/copy", body: EmptyBody(), authorized: true)
            Pro100APIClient.dataTask(req) { result in
                switch result {
                case .failure(let e):
                    completion(.failure(e))
                case .success((let http, let data)):
                    guard (200...299).contains(http.statusCode) else {
                        completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                        return
                    }
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }


    func listFavorites(
        page: Int,
        limit: Int = 20,
        completion: @escaping (Result<DecksListResponse, AuthError>) -> Void
    ) {
        let q: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        let req = Pro100APIClient.get(path: "favorites", query: q, authorized: true)
        Pro100APIClient.dataTask(req) { result in
            self.decodeDecksList(result, completion: completion)
        }
    }

    func addFavorite(deckId: Int, completion: @escaping (Result<FavoriteResponseDTO, AuthError>) -> Void) {
        do {
            let req = try Pro100APIClient.postJSON(path: "decks/\(deckId)/favorite", body: EmptyBody(), authorized: true)
            Pro100APIClient.dataTask(req) { result in
                self.decodeFavorite(result, completion: completion)
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }

    func removeFavorite(deckId: Int, completion: @escaping (Result<FavoriteResponseDTO, AuthError>) -> Void) {
        let req = Pro100APIClient.delete(path: "decks/\(deckId)/favorite", authorized: true)
        Pro100APIClient.dataTask(req) { result in
            self.decodeFavorite(result, completion: completion)
        }
    }


    func getDeckProgress(deckId: Int, completion: @escaping (Result<DeckProgressDTO, AuthError>) -> Void) {
        let req = Pro100APIClient.get(path: "decks/\(deckId)/progress", authorized: true)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let decoded = try? Pro100APIClient.jsonDecoder.decode(DeckProgressDTO.self, from: data) else {
                    completion(.failure(.unknown("Некорректный ответ прогресса.")))
                    return
                }
                completion(.success(decoded))
            }
        }
    }

    func startStudySession(deckId: Int, completion: @escaping (Result<StartStudyResponseDTO, AuthError>) -> Void) {
        do {
            let req = try Pro100APIClient.postJSON(path: "decks/\(deckId)/study/start", body: EmptyBody(), authorized: true)
            Pro100APIClient.dataTask(req) { result in
                switch result {
                case .failure(let e):
                    completion(.failure(e))
                case .success((let http, let data)):
                    guard (200...299).contains(http.statusCode) else {
                        completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                        return
                    }
                    guard let decoded = try? Pro100APIClient.jsonDecoder.decode(StartStudyResponseDTO.self, from: data) else {
                        completion(.failure(.unknown("Некорректный ответ старта обучения.")))
                        return
                    }
                    completion(.success(decoded))
                }
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }

    func listStudySessions(limit: Int = 20, completion: @escaping (Result<[StudySessionDTO], AuthError>) -> Void) {
        let q: [String: String] = ["limit": "\(limit)"]
        let req = Pro100APIClient.get(path: "study/sessions", query: q, authorized: true)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let decoded = try? Pro100APIClient.jsonDecoder.decode(StudySessionsListResponseDTO.self, from: data) else {
                    completion(.failure(.unknown("Некорректный ответ списка сессий.")))
                    return
                }
                completion(.success(decoded.sessions))
            }
        }
    }

    func getStudySession(id: Int, completion: @escaping (Result<StudySessionDTO, AuthError>) -> Void) {
        let req = Pro100APIClient.get(path: "study/sessions/\(id)", authorized: true)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let decoded = try? Pro100APIClient.jsonDecoder.decode(StudySessionDTO.self, from: data) else {
                    completion(.failure(.unknown("Некорректный ответ сессии.")))
                    return
                }
                completion(.success(decoded))
            }
        }
    }

    func reviewStudyCard(
        sessionId: Int,
        cardId: Int,
        quality: Int,
        completion: @escaping (Result<ReviewStudyResponseDTO, AuthError>) -> Void
    ) {
        let body = ReviewStudyCardBody(cardId: cardId, quality: quality)
        do {
            let req = try Pro100APIClient.postJSON(path: "study/sessions/\(sessionId)/review", body: body, authorized: true)
            Pro100APIClient.dataTask(req) { result in
                switch result {
                case .failure(let e):
                    completion(.failure(e))
                case .success((let http, let data)):
                    guard (200...299).contains(http.statusCode) else {
                        completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                        return
                    }
                    guard let decoded = try? Pro100APIClient.jsonDecoder.decode(ReviewStudyResponseDTO.self, from: data) else {
                        completion(.failure(.unknown("Некорректный ответ проверки карточки.")))
                        return
                    }
                    completion(.success(decoded))
                }
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }

    func finishStudySession(
        sessionId: Int,
        completion: @escaping (Result<FinishStudyResponseDTO, AuthError>) -> Void
    ) {
        do {
            let req = try Pro100APIClient.postJSON(path: "study/sessions/\(sessionId)/finish", body: EmptyBody(), authorized: true)
            Pro100APIClient.dataTask(req) { result in
                switch result {
                case .failure(let e):
                    completion(.failure(e))
                case .success((let http, let data)):
                    guard (200...299).contains(http.statusCode) else {
                        completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                        return
                    }
                    guard let decoded = try? Pro100APIClient.jsonDecoder.decode(FinishStudyResponseDTO.self, from: data) else {
                        completion(.failure(.unknown("Некорректный ответ завершения сессии.")))
                        return
                    }
                    completion(.success(decoded))
                }
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }


    func listMyCards(
        page: Int,
        limit: Int = 20,
        search: String? = nil,
        categoryId: Int? = nil,
        tagId: Int? = nil,
        completion: @escaping (Result<CardsListResponse, AuthError>) -> Void
    ) {
        var q: [String: String] = [
            "page": "\(page)",
            "limit": "\(limit)"
        ]
        if let s = search, !s.isEmpty { q["search"] = s }
        if let c = categoryId { q["category_id"] = "\(c)" }
        if let t = tagId { q["tag_id"] = "\(t)" }
        let req = Pro100APIClient.get(path: "cards", query: q, authorized: true)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let decoded = try? Pro100APIClient.jsonDecoder.decode(CardsListResponse.self, from: data) else {
                    completion(.failure(.unknown("Некорректный ответ карточек.")))
                    return
                }
                completion(.success(decoded))
            }
        }
    }

    func getMyCard(id: Int, completion: @escaping (Result<CardListItemDTO, AuthError>) -> Void) {
        let req = Pro100APIClient.get(path: "cards/\(id)", authorized: true)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                guard let decoded = try? Pro100APIClient.jsonDecoder.decode(CardListItemDTO.self, from: data) else {
                    completion(.failure(.unknown("Некорректный ответ карточки.")))
                    return
                }
                completion(.success(decoded))
            }
        }
    }

    func createCardInDeck(
        deckId: Int,
        question: String,
        answer: String,
        categoryId: Int?,
        tagIds: [Int],
        completion: @escaping (Result<CardItemDTO, AuthError>) -> Void
    ) {
        let body = CreateCardInDeckBody(
            question: question,
            answer: answer,
            categoryId: categoryId,
            tagIds: tagIds.isEmpty ? nil : tagIds
        )
        do {
            let req = try Pro100APIClient.postJSON(path: "decks/\(deckId)/cards", body: body, authorized: true)
            Pro100APIClient.dataTask(req) { result in
                self.decodeCardItem(result, completion: completion)
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }

    func updateCard(
        id: Int,
        question: String?,
        answer: String?,
        categoryId: Int?,
        tagIds: [Int]?,
        completion: @escaping (Result<CardItemDTO, AuthError>) -> Void
    ) {
        let body = UpdateCardBody(
            question: question,
            answer: answer,
            categoryId: categoryId,
            tagIds: tagIds
        )
        do {
            let req = try Pro100APIClient.putJSON(path: "cards/\(id)", body: body, authorized: true)
            Pro100APIClient.dataTask(req) { result in
                self.decodeCardItem(result, completion: completion)
            }
        } catch {
            completion(.failure(.unknown("Сбой запроса.")))
        }
    }

    func deleteCard(id: Int, completion: @escaping (Result<Void, AuthError>) -> Void) {
        let req = Pro100APIClient.delete(path: "cards/\(id)", authorized: true)
        Pro100APIClient.dataTask(req) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success((let http, let data)):
                guard (200...299).contains(http.statusCode) else {
                    completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                    return
                }
                completion(.success(()))
            }
        }
    }


    func resolveTagIds(
        names: [String],
        allTags: [APITag],
        completion: @escaping (Result<[Int], AuthError>) -> Void
    ) {
        let list = names.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        guard !list.isEmpty else {
            completion(.success([]))
            return
        }
        var byName: [String: Int] = Dictionary(
            allTags.map { ($0.name.lowercased(), $0.id) },
            uniquingKeysWith: { first, _ in first }
        )
        func processNext(index: Int, acc: [Int]) {
            if index == list.count {
                completion(.success(acc))
                return
            }
            let n = list[index]
            let key = n.lowercased()
            if let id = byName[key] {
                processNext(index: index + 1, acc: acc + [id])
                return
            }
            createTag(name: n) { r in
                switch r {
                case .failure(let e):
                    completion(.failure(e))
                case .success(let tag):
                    byName[tag.name.lowercased()] = tag.id
                    processNext(index: index + 1, acc: acc + [tag.id])
                }
            }
        }
        processNext(index: 0, acc: [])
    }

    private func decodeDecksList(
        _ result: Result<(HTTPURLResponse, Data), AuthError>,
        completion: @escaping (Result<DecksListResponse, AuthError>) -> Void
    ) {
        switch result {
        case .failure(let e):
            completion(.failure(e))
        case .success((let http, let data)):
            guard (200...299).contains(http.statusCode) else {
                completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                return
            }
            guard let decoded = try? Pro100APIClient.jsonDecoder.decode(DecksListResponse.self, from: data) else {
                completion(.failure(.unknown("Некорректный ответ наборов.")))
                return
            }
            completion(.success(decoded))
        }
    }

    private func decodeDeckFull(
        _ result: Result<(HTTPURLResponse, Data), AuthError>,
        completion: @escaping (Result<DeckFullDTO, AuthError>) -> Void
    ) {
        switch result {
        case .failure(let e):
            completion(.failure(e))
        case .success((let http, let data)):
            guard (200...299).contains(http.statusCode) else {
                completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                return
            }
            guard let deck = try? Pro100APIClient.jsonDecoder.decode(DeckFullDTO.self, from: data) else {
                completion(.failure(.unknown("Некорректный ответ набора.")))
                return
            }
            completion(.success(deck))
        }
    }

    private func decodeCardItem(
        _ result: Result<(HTTPURLResponse, Data), AuthError>,
        completion: @escaping (Result<CardItemDTO, AuthError>) -> Void
    ) {
        switch result {
        case .failure(let e):
            completion(.failure(e))
        case .success((let http, let data)):
            guard (200...299).contains(http.statusCode) else {
                completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                return
            }
            guard let card = try? Pro100APIClient.jsonDecoder.decode(CardItemDTO.self, from: data) else {
                completion(.failure(.unknown("Некорректный ответ карточки.")))
                return
            }
            completion(.success(card))
        }
    }

    private func decodeFavorite(
        _ result: Result<(HTTPURLResponse, Data), AuthError>,
        completion: @escaping (Result<FavoriteResponseDTO, AuthError>) -> Void
    ) {
        switch result {
        case .failure(let e):
            completion(.failure(e))
        case .success((let http, let data)):
            guard (200...299).contains(http.statusCode) else {
                completion(.failure(Pro100APIClient.parseError(data, status: http.statusCode)))
                return
            }
            guard let decoded = try? Pro100APIClient.jsonDecoder.decode(FavoriteResponseDTO.self, from: data) else {
                completion(.failure(.unknown("Некорректный ответ избранного.")))
                return
            }
            completion(.success(decoded))
        }
    }

    private static func trimJSONBOM(_ data: Data) -> Data {
        guard data.count >= 3 else { return data }
        if data[0] == 0xEF && data[1] == 0xBB && data[2] == 0xBF {
            return data.advanced(by: 3)
        }
        return data
    }

    private static func decodeTagsFromTagsKeyJSON(_ data: Data) -> [APITag]? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        guard obj.keys.contains("tags") else { return nil }
        switch obj["tags"] {
        case is NSNull: return []
        case let arr as [Any]:
            var out: [APITag] = []
            for el in arr {
                guard let d = el as? [String: Any],
                      let id = intFromJSONValue(d["id"]),
                      let name = d["name"] as? String else { return nil }
                out.append(APITag(id: id, name: name))
            }
            return out
        default: return nil
        }
    }

    private static func decodeCategoriesFromCategoriesKeyJSON(_ data: Data) -> [APICategory]? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        guard obj.keys.contains("categories") else { return nil }
        switch obj["categories"] {
        case is NSNull: return []
        case let arr as [Any]:
            var out: [APICategory] = []
            for el in arr {
                guard let d = el as? [String: Any],
                      let id = intFromJSONValue(d["id"]),
                      let name = d["name"] as? String else { return nil }
                out.append(APICategory(id: id, name: name))
            }
            return out
        default: return nil
        }
    }

    private static func decodeTagsList(_ data: Data) -> [APITag]? {
        let data = trimJSONBOM(data)
        if data.isEmpty { return [] }
        if let manual = decodeTagsFromTagsKeyJSON(data) { return manual }
        let d = Pro100APIClient.jsonDecoder
        if let arr = try? d.decode([APITag].self, from: data) { return arr }
        if let r = try? d.decode(TagsResponse.self, from: data) { return r.tags }
        struct DataArr: Decodable { let data: [APITag] }
        if let w = try? d.decode(DataArr.self, from: data) { return w.data }
        struct ItemsArr: Decodable { let items: [APITag] }
        if let w = try? d.decode(ItemsArr.self, from: data) { return w.items }
        if let loose = looseTagsFromJSONObject(data) { return loose }
        return nil
    }

    private static func decodeCategoriesList(_ data: Data) -> [APICategory]? {
        let data = trimJSONBOM(data)
        if data.isEmpty { return [] }
        if let manual = decodeCategoriesFromCategoriesKeyJSON(data) { return manual }
        let d = Pro100APIClient.jsonDecoder
        if let arr = try? d.decode([APICategory].self, from: data) { return arr }
        if let r = try? d.decode(CategoriesResponse.self, from: data) { return r.categories }
        struct DataArr: Decodable { let data: [APICategory] }
        if let w = try? d.decode(DataArr.self, from: data) { return w.data }
        struct ItemsArr: Decodable { let items: [APICategory] }
        if let w = try? d.decode(ItemsArr.self, from: data) { return w.items }
        if let loose = looseCategoriesFromJSONObject(data) { return loose }
        return nil
    }


    private static func intFromJSONValue(_ v: Any?) -> Int? {
        switch v {
        case let i as Int: return i
        case let i as Int64: return Int(i)
        case let s as String: return Int(s)
        case let d as Double: return Int(d)
        default: return nil
        }
    }

    private static func findHomogeneousObjectArray(
        in any: Any,
        predicate: ([String: Any]) -> Bool
    ) -> [[String: Any]]? {
        if let arr = any as? [Any] {
            let dicts = arr.compactMap { $0 as? [String: Any] }
            if dicts.count == arr.count, !dicts.isEmpty, dicts.allSatisfy(predicate) {
                return dicts
            }
            for el in arr {
                if let found = findHomogeneousObjectArray(in: el, predicate: predicate) { return found }
            }
        }
        if let dict = any as? [String: Any] {
            for (_, v) in dict {
                if let found = findHomogeneousObjectArray(in: v, predicate: predicate) { return found }
            }
        }
        return nil
    }

    private static func looseTagsFromJSONObject(_ data: Data) -> [APITag]? {
        guard let root = try? JSONSerialization.jsonObject(with: data) else { return nil }
        guard let dicts = findHomogeneousObjectArray(in: root, predicate: isLooseTagDict) else { return nil }
        let tags = dicts.compactMap { looseTagFromDict($0) }
        return tags.isEmpty ? nil : tags
    }

    private static func isLooseTagDict(_ d: [String: Any]) -> Bool {
        if d["question"] != nil || d["answer"] != nil { return false }
        if d["is_public"] != nil || d["isPublic"] != nil { return false }
        let id = intFromJSONValue(d["id"]) ?? intFromJSONValue(d["tag_id"])
        guard id != nil else { return false }
        let name = (d["name"] as? String) ?? (d["tag_name"] as? String)
        return name != nil
    }

    private static func looseTagFromDict(_ d: [String: Any]) -> APITag? {
        guard let id = intFromJSONValue(d["id"]) ?? intFromJSONValue(d["tag_id"]) else { return nil }
        guard let name = (d["name"] as? String) ?? (d["tag_name"] as? String) else { return nil }
        return APITag(id: id, name: name)
    }

    private static func looseCategoriesFromJSONObject(_ data: Data) -> [APICategory]? {
        guard let root = try? JSONSerialization.jsonObject(with: data) else { return nil }
        guard let dicts = findHomogeneousObjectArray(in: root, predicate: isLooseCategoryDict) else { return nil }
        let list = dicts.compactMap { looseCategoryFromDict($0) }
        return list.isEmpty ? nil : list
    }

    private static func isLooseCategoryDict(_ d: [String: Any]) -> Bool {
        if d["question"] != nil || d["answer"] != nil { return false }
        if d["is_public"] != nil || d["isPublic"] != nil { return false }
        let id = intFromJSONValue(d["id"]) ?? intFromJSONValue(d["category_id"])
        guard id != nil else { return false }
        let name = (d["name"] as? String) ?? (d["title"] as? String)
        return name != nil
    }

    private static func looseCategoryFromDict(_ d: [String: Any]) -> APICategory? {
        guard let id = intFromJSONValue(d["id"]) ?? intFromJSONValue(d["category_id"]) else { return nil }
        guard let name = (d["name"] as? String) ?? (d["title"] as? String) else { return nil }
        return APICategory(id: id, name: name)
    }
}


// MARK: - APICategory
struct APICategory: Decodable, Hashable {
    let id: Int
    let name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    private enum CodingKeys: String, CodingKey { case id, name }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        if let i = try? c.decode(Int.self, forKey: .id) {
            id = i
        } else if let d = try? c.decode(Double.self, forKey: .id) {
            id = Int(d)
        } else if let s = try? c.decode(String.self, forKey: .id), let i = Int(s) {
            id = i
        } else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: c, debugDescription: "Expected Int id")
        }
    }
}

// MARK: - APITag
struct APITag: Decodable, Hashable {
    let id: Int
    let name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    private enum CodingKeys: String, CodingKey { case id, name }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        if let i = try? c.decode(Int.self, forKey: .id) {
            id = i
        } else if let d = try? c.decode(Double.self, forKey: .id) {
            id = Int(d)
        } else if let s = try? c.decode(String.self, forKey: .id), let i = Int(s) {
            id = i
        } else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: c, debugDescription: "Expected Int id")
        }
    }
}

private struct CreateNamedBody: Encodable {
    let name: String
}

// MARK: - CategoriesResponse
struct CategoriesResponse: Decodable {
    let categories: [APICategory]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        categories = try c.decodeIfPresent([APICategory].self, forKey: .categories) ?? []
    }

    private enum CodingKeys: String, CodingKey { case categories }
}

// MARK: - TagsResponse
struct TagsResponse: Decodable {
    let tags: [APITag]

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        tags = try c.decodeIfPresent([APITag].self, forKey: .tags) ?? []
    }

    private enum CodingKeys: String, CodingKey { case tags }
}

// MARK: - DecksListResponse
struct DecksListResponse: Decodable {
    let decks: [DeckListItemDTO]
    let pagination: PaginationDTO
}

// MARK: - PublicDecksListResponse
struct PublicDecksListResponse: Decodable {
    let decks: [PublicDeckListItemDTO]
    let pagination: PaginationDTO
}

// MARK: - PaginationDTO
struct PaginationDTO: Decodable {
    let page: Int
    let limit: Int
    let total: Int
}

// MARK: - DeckListItemDTO
struct DeckListItemDTO: Decodable {
    let id: Int
    let title: String
    let description: String?
    let category: APICategory?
    let tags: [APITag]?
    let isPublic: Bool
    let cardsCount: Int
    let createdAt: String?
}

// MARK: - DeckFullDTO
struct DeckFullDTO: Decodable {
    let id: Int
    let title: String
    let description: String?
    let category: APICategory?
    let tags: [APITag]?
    let isPublic: Bool
    let cards: [CardInDeckDTO]?
    let cardsCount: Int?
}

// MARK: - CardInDeckDTO
struct CardInDeckDTO: Decodable {
    let id: Int
    let question: String
    let answer: String
    let category: APICategory?
    let tags: [APITag]?
}

// MARK: - PublicDeckListItemDTO
struct PublicDeckListItemDTO: Decodable {
    let id: Int
    let title: String
    let description: String?
    let category: APICategory?
    let tags: [APITag]?
    let cardsCount: Int
    let author: DeckAuthorDTO
    let createdAt: String
}

// MARK: - DeckAuthorDTO
struct DeckAuthorDTO: Decodable {
    let id: Int
    let username: String?
    let avatarUrl: String?
}

// MARK: - PublicDeckDetailDTO
struct PublicDeckDetailDTO: Decodable {
    let id: Int
    let title: String
    let description: String?
    let category: APICategory?
    let tags: [APITag]?
    let cardsCount: Int
    let author: DeckAuthorDTO
    let cards: [PublicCardItemDTO]
}

// MARK: - PublicCardItemDTO
struct PublicCardItemDTO: Decodable {
    let id: Int
    let question: String
    let answer: String
}

// MARK: - CardsListResponse
struct CardsListResponse: Decodable {
    let cards: [CardListItemDTO]
    let pagination: PaginationDTO
}

// MARK: - CardListItemDTO
struct CardListItemDTO: Decodable {
    let id: Int
    let question: String
    let answer: String
    let deck: DeckBriefDTO
    let category: APICategory?
    let tags: [APITag]?
    let createdAt: String?
}

// MARK: - DeckBriefDTO
struct DeckBriefDTO: Decodable {
    let id: Int
    let title: String
}

// MARK: - CardItemDTO
struct CardItemDTO: Decodable {
    let id: Int
    let question: String
    let answer: String
    let deck: DeckBriefDTO
    let category: APICategory?
    let tags: [APITag]?
    let createdAt: String?
}

private struct CreateDeckBody: Encodable {
    let title: String
    let description: String?
    let categoryId: Int?
    let isPublic: Bool
    let tagIds: [Int]?
}

private struct UpdateDeckBody: Encodable {
    let title: String?
    let description: String?
    let categoryId: Int?
    let isPublic: Bool?
    let tagIds: [Int]?
}

private struct CreateCardInDeckBody: Encodable {
    let question: String
    let answer: String
    let categoryId: Int?
    let tagIds: [Int]?
}

private struct UpdateCardBody: Encodable {
    let question: String?
    let answer: String?
    let categoryId: Int?
    let tagIds: [Int]?
}

private struct EmptyBody: Encodable {}

private struct ReviewStudyCardBody: Encodable {
    let cardId: Int
    let quality: Int
}

// MARK: - FavoriteResponseDTO
struct FavoriteResponseDTO: Decodable {
    let deckId: Int
    let isFavorite: Bool
    let message: String
}

// MARK: - DeckProgressDTO
struct DeckProgressDTO: Decodable {
    let deckId: Int
    let cardsTotal: Int
    let cardsNew: Int
    let cardsDue: Int
    let cardsMastered: Int
}

// MARK: - StudyCardDTO
struct StudyCardDTO: Decodable {
    let id: Int
    let question: String
    let answer: String
    let isNew: Bool?
}

// MARK: - StartStudyResponseDTO
struct StartStudyResponseDTO: Decodable {
    let sessionId: Int?
    let card: StudyCardDTO?
    let totalCards: Int?
    let status: String?
    let message: String?
}

// MARK: - ReviewStudyResponseDTO
struct ReviewStudyResponseDTO: Decodable {
    let nextCard: StudyCardDTO?
    let summary: StudySessionSummaryDTO?
    let progress: CardProgressDTO?
}

// MARK: - StudySessionSummaryDTO
struct StudySessionSummaryDTO: Decodable {
    let sessionId: Int
    let cardsReviewed: Int
    let cardsCorrect: Int
    let accuracyPct: Double
    let duration: String
}

// MARK: - CardProgressDTO
struct CardProgressDTO: Decodable {
    let cardId: Int
    let status: String?
    let repetitions: Int?
    let intervalDays: Int?
    let easeFactor: Double?
    let nextReviewAt: String
}

// MARK: - StudySessionDTO
struct StudySessionDTO: Decodable {
    let id: Int
    let deckId: Int
    let cardsTotal: Int
    let cardsReviewed: Int
    let cardsCorrect: Int
    let status: String
    let startedAt: String
    let endedAt: String?
}

// MARK: - StudySessionsListResponseDTO
struct StudySessionsListResponseDTO: Decodable {
    let sessions: [StudySessionDTO]
}

// MARK: - FinishStudyResponseDTO
struct FinishStudyResponseDTO: Decodable {
    let session: StudySessionDTO
    let summary: StudySessionSummaryDTO
}


// MARK: - StudyContentMappers
enum StudyContentMappers {
    static func cardSet(from item: DeckListItemDTO) -> CardSetModel {
        CardSetModel(
            id: "\(item.id)",
            title: item.title,
            description: item.description ?? "",
            cardCount: item.cardsCount,
            category: item.category?.name ?? "Без категории",
            tags: (item.tags ?? []).map(\.name),
            isPrivate: !item.isPublic,
            cards: []
        )
    }

    static func cardSet(from deck: DeckFullDTO) -> CardSetModel {
        let count = deck.cardsCount ?? (deck.cards?.count ?? 0)
        return CardSetModel(
            id: "\(deck.id)",
            title: deck.title,
            description: deck.description ?? "",
            cardCount: count,
            category: deck.category?.name ?? "Без категории",
            tags: (deck.tags ?? []).map(\.name),
            isPrivate: !deck.isPublic,
            cards: (deck.cards ?? []).map { c in
                cardModel(c, deckId: deck.id, setTitle: deck.title)
            }
        )
    }

    static func cardModel(_ c: CardInDeckDTO, deckId: Int, setTitle: String) -> CardModel {
        CardModel(
            id: "\(c.id)",
            question: c.question,
            answer: c.answer,
            setId: "\(deckId)",
            setTitle: setTitle,
            category: c.category?.name ?? "Без категории",
            tags: (c.tags ?? []).map(\.name)
        )
    }

    static func cardModel(from listItem: CardListItemDTO) -> CardModel {
        CardModel(
            id: "\(listItem.id)",
            question: listItem.question,
            answer: listItem.answer,
            setId: "\(listItem.deck.id)",
            setTitle: listItem.deck.title,
            category: listItem.category?.name ?? "Без категории",
            tags: (listItem.tags ?? []).map(\.name)
        )
    }

    static func publicSet(from item: PublicDeckListItemDTO) -> PublicSetModel {
        let author = item.author.username?.isEmpty == false ? item.author.username! : "Пользователь \(item.author.id)"
        let date = publicDate(from: item.createdAt) ?? Date()
        return PublicSetModel(
            id: "\(item.id)",
            title: item.title,
            cardCount: item.cardsCount,
            category: item.category?.name ?? "Без категории",
            authorName: author,
            authorAvatarURL: item.author.avatarUrl,
            popularity: item.cardsCount,
            createdAt: date
        )
    }

    static func cardSetFromPublic(detail: PublicDeckDetailDTO) -> CardSetModel {
        let cards: [CardModel] = detail.cards.map { c in
            CardModel(
                id: "\(c.id)",
                question: c.question,
                answer: c.answer,
                setId: "\(detail.id)",
                setTitle: detail.title,
                category: detail.category?.name ?? "Без категории",
                tags: (detail.tags ?? []).map(\.name)
            )
        }
        return CardSetModel(
            id: "\(detail.id)",
            title: detail.title,
            description: detail.description ?? "",
            cardCount: detail.cardsCount,
            category: detail.category?.name ?? "Без категории",
            tags: (detail.tags ?? []).map(\.name),
            isPrivate: false,
            cards: cards
        )
    }

    private static func publicDate(from raw: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = iso.date(from: raw) { return d }
        iso.formatOptions = [.withInternetDateTime]
        return iso.date(from: raw)
    }
}
