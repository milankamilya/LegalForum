//
//  Constants.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//


import Foundation

struct Constants {
    
    private static let baseUrlPath = "http://localhost:3001"
    
    struct Urls {
        
        // User
        static let createUser = URL(string: "\(baseUrlPath)/user/create")!
        static let login = URL(string: "\(baseUrlPath)/user/login")!
        static let logout = URL(string: "\(baseUrlPath)/user/logout")!
        static let users = URL(string: "\(baseUrlPath)/user/list")!
        
        // Query
        static let createQuery = URL(string: "\(baseUrlPath)/query/create")!
        static let publicQueries = URL(string: "\(baseUrlPath)/query/list/public")!
        static let queries = URL(string: "\(baseUrlPath)/query/list")!
        
        static let assignQuery = URL(string: "\(baseUrlPath)/query/assign")!
        static let replyOnQuery = URL(string: "\(baseUrlPath)/query/answer")!
        static let publicReplyOnQuery = URL(string: "\(baseUrlPath)/query/answer/public")!

        static func query(id: String) -> URL {
            URL(string: "\(baseUrlPath)/query/\(id)")!
        }
    }
    
    struct Headers {
        static let token = "x-access-token"
    }
    
    struct StoreKey {
        static let token = "auth-token"
    }
}
