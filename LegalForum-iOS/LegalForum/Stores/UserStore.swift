//
//  UserStore.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import Foundation
import Observation

@Observable
class UserStore: ObservableObject {
    private(set) var loggedInUser: User?
    private(set) var isLoading: Bool = false
    private(set) var message: String? = nil
    private(set) var users: [User] = []
    
    var token: String? {
        guard let _ = loggedInUser else { return nil }
        return userDefault.string(forKey: tokenKey)
    }
    
    private let httpClient: HTTPClient
    private let userDefault: UserDefaults
    private let tokenKey = Constants.StoreKey.token
    init(httpClient: HTTPClient, userDefault: UserDefaults) {
        self.httpClient = httpClient
        self.userDefault = userDefault
    }
    
    func login(req: UserSignInRequest) async throws {
        isLoading = true
        let data = try JSONEncoder().encode(req)
        let resource = Resource(url: Constants.Urls.login, method: .POST , modelType: UserSignInResponse.self, body: data)
        let response = try await httpClient.load(resource: resource)
        let res = response.data
        loggedInUser = res?.user
        userDefault.set(res?.token, forKey: tokenKey)
        isLoading = false
    }
    
    func logout() async throws {
        isLoading = true
        
        var headers = [String: String]()
        if let token = token {
            headers[Constants.Headers.token] = token
        } else {
            throw HTTPError.invalidToken
        }
        
        let resource = Resource(url: Constants.Urls.logout, method: .POST , modelType: EmptyResponse.self, headers: headers)
        let _ = try await httpClient.load(resource: resource)
        loggedInUser = nil
        userDefault.removeObject(forKey: tokenKey)
        isLoading = false
    }
    
    func signup(req: UserSignUpRequest) async throws {
        isLoading = true
        let data = try JSONEncoder().encode(req)
        let resource = Resource(url: Constants.Urls.createUser, method: .POST , modelType: User.self, body: data)
        let _ = try await httpClient.load(resource: resource)
        isLoading = false
    }
    
    func list(req: UserListRequest) async throws {
        isLoading = true
        users = []
        var headers = [String: String]()
        if let token = token {
            headers[Constants.Headers.token] = token
        } else {
            throw HTTPError.invalidToken
        }
        
        let data = try JSONEncoder().encode(req)
        let resource = Resource(url: Constants.Urls.users, method: .POST , modelType: [User].self, headers: headers, body: data)
        let response = try await httpClient.load(resource: resource)
        users = response.data ?? []
        isLoading = false
    }
}
