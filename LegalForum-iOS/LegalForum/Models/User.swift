//
//  User.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//


import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case normal
    case moderator
    case panelist
    case admin

    var id: Self { return self }
}

struct User: Codable, Hashable, Identifiable  {
    var id: String
    let firstName: String
    let lastName: String
    let email: String
    let role: UserRole
    let language: String
    let isAnonymous: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case email
        case role
        case language
        case isAnonymous
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

extension User {
    var fullName: String {
        isAnonymous ? "Anonymous" : "\(firstName) \(lastName)"
    }
    var isModarator: Bool {
        role == .moderator
    }
    var isPanelist: Bool {
        role == .panelist
    }
}

struct UserSignInRequest: Codable, Hashable {
    let email: String
    let password: String
}

struct UserSignInResponse: Codable, Hashable {
    let token: String?
    let user: User?
}

struct UserSignUpRequest: Codable, Hashable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let isAnonymous: Bool
    let role: String 
}

struct UserListRequest: Codable, Hashable {
    let role: String
}

struct EmptyResponse: Codable { }
