//
//  LegalForumApp.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import SwiftUI

@main
struct LegalForumApp: App {
    private static let httpClient = HTTPClient()
    
    @StateObject private var userStore: UserStore
    @StateObject private var queryStore: QueryStore

    init() {
        // Create a local instance of UserStore
        let userStore = UserStore(httpClient: Self.httpClient, userDefault: .standard)
        _userStore = StateObject(wrappedValue: userStore)
        
        // Use the local instance of UserStore to initialize QueryStore
        _queryStore = StateObject(wrappedValue: QueryStore(httpClient: Self.httpClient, userStore: userStore))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                QuerySearchView()
            }
            .environment(userStore)
            .environment(queryStore)
        }
    }
}

