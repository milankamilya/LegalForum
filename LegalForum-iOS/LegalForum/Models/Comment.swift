//
//  Comment.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//


import Foundation

struct Comment: Codable, Hashable, Identifiable  {
    let id: String
    let detail: String
    let createdAt: Date
    let createdBy: User?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case detail
        case createdAt
        case createdBy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        detail = try container.decode(String.self, forKey: .detail)
        createdBy = try container.decodeIfPresent(User.self, forKey: .createdBy)

        // Convert timestamp in milliseconds to Date
        let timestamp = try container.decode(Int64.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}

extension Comment {
    var author: String {
        createdBy == nil ? "Anonymous" : createdBy!.fullName
    }
}
