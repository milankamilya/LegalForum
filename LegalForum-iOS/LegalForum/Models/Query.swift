//
//  Query.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import Foundation

enum QueryCategory: String, Codable, CaseIterable, Identifiable {
    case general = "general"
    case technical = "technical"
    case billing = "billing"
    case contracts = "contracts"
    case intellectualProperty = "intellectual property"
    case employment = "employment"
    case familyLaw = "family law"
    case criminalLaw = "criminal law"
    case corporateLaw = "corporate law"
    case taxation = "taxation"
    case realEstate = "real estate"
    case immigration = "immigration"
    case litigation = "litigation"
    case privacy = "privacy"
    case compliance = "compliance"
    case other = "other"
    
    var id: Self { return self }
}

enum QueryStatus: String, Codable, CaseIterable, Identifiable {
    case opened
    case assigned
    case answered
    case resolved
    
    var id: Self { return self }
    
    var image: String {
        switch self {
        case .opened: return "document.badge.plus"
        case .answered: return "captions.bubble"
        case .assigned: return "bubble.and.pencil"
        case .resolved: return "checkmark.message"
        }
    }
}

struct Query: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let status: QueryStatus
    let createdAt: Date
    let createdBy: User?
    let moderator: User?
    let panelist: User?
    let isPrivate: Bool
    let tags: [String]?
    let category: QueryCategory
    let comments: [Comment]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case detail
        case status
        case createdAt
        case createdBy
        case moderator
        case panelist
        case isPrivate
        case tags
        case category
        case comments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        detail = try container.decode(String.self, forKey: .detail)
        status = try container.decode(QueryStatus.self, forKey: .status)
        createdBy = try container.decodeIfPresent(User.self, forKey: .createdBy)
        moderator = try container.decodeIfPresent(User.self, forKey: .moderator)
        panelist = try container.decodeIfPresent(User.self, forKey: .panelist)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        category = try container.decode(QueryCategory.self, forKey: .category)
        comments = try container.decodeIfPresent([Comment].self, forKey: .comments)
        
        let timestamp = try container.decode(Int64.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
    
    static func == (lhs: Query, rhs: Query) -> Bool {
        lhs.id == rhs.id
    }
}

extension Query {
    var author: String {
        createdBy == nil ? "Anonymous" : createdBy!.fullName
    }
    var isAssignable: Bool {
        status == .opened
    }

    var isReplyable: Bool {
        status == .assigned || status == .answered
    }
}

struct QuerySearchRequest: Codable, Hashable {
    var categories: [String] = []
    var statuses: [String] = []
    let search: String
    var page: Int = 1
    var limit: Int = 200
}


struct CreateQueryRequest: Codable, Hashable {
    let title: String
    let detail: String
    let category: String
    let isPrivate: Bool
}

struct AssignQueryRequest: Codable, Hashable {
    let id: String
    let panelist: String
}

struct AnswerQueryRequest: Codable, Hashable {
    let id: String
    let answer: String
}
