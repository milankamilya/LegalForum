//
//  QueryStore.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import Foundation

@Observable
class QueryStore: ObservableObject {
    private(set) var queries: [Query] = []
    private(set) var selectedQuery: Query? = nil
    private(set) var isLoading: Bool = false
    private(set) var message: String? = nil
    
    private let httpClient: HTTPClient
    private let userStore: UserStore
    init(httpClient: HTTPClient, userStore: UserStore) {
        self.httpClient = httpClient
        self.userStore = userStore
    }
    
    func createQuery(_ req: CreateQueryRequest) async throws {
        isLoading = true

        var headers = [String: String]()
        if let token = userStore.token {
            headers[Constants.Headers.token] = token
        } else {
            throw HTTPError.invalidToken
        }
        
        let data = try JSONEncoder().encode(req)
        let resource = Resource(url: Constants.Urls.createQuery, method: .POST , modelType: Query.self, headers: headers, body: data)
        let _ = try await httpClient.load(resource: resource)
        
        isLoading = false
    }
    
    func loadQueries(_ req: QuerySearchRequest ) async throws {
        isLoading = true

        var url: URL = Constants.Urls.publicQueries
        var headers = [String: String]()
        if let token = userStore.token {
            url = Constants.Urls.queries
            headers[Constants.Headers.token] = token
        }
        
        let data = try JSONEncoder().encode(req)
        let resource = Resource(url: url, method: .POST , modelType: [Query].self, headers: headers, body: data)
        let response = try await httpClient.load(resource: resource)
        queries = response.data ?? []
        
        isLoading = false
    }
    
    func loadQuery(_ id: String) async throws {
        let url = Constants.Urls.query(id: id)
        var headers = [String: String]()
        if let token = userStore.token {
            headers[Constants.Headers.token] = token
        }
        
        let resource = Resource(url: url, method: .GET , modelType: Query.self, headers: headers)
        let response = try await httpClient.load(resource: resource)
        selectedQuery = response.data
    }

    func assignQuery(_ req: AssignQueryRequest) async throws {
        isLoading = true

        var headers = [String: String]()
        if let token = userStore.token {
            headers[Constants.Headers.token] = token
        } else {
            throw HTTPError.invalidToken
        }
        
        let data = try JSONEncoder().encode(req)
        let resource = Resource(url: Constants.Urls.assignQuery, method: .POST , modelType: Query.self, headers: headers, body: data)
        let _ = try await httpClient.load(resource: resource)
        isLoading = false
    }

    func answerToQuery(_ req: AnswerQueryRequest) async throws {
        isLoading = true
        var url: URL = Constants.Urls.publicReplyOnQuery
        var headers = [String: String]()
        if let token = userStore.token {
            url = Constants.Urls.replyOnQuery
            headers[Constants.Headers.token] = token
        }

        let data = try JSONEncoder().encode(req)
        let resource = Resource(url: url, method: .POST , modelType: Query.self, headers: headers, body: data)
        let _ = try await httpClient.load(resource: resource)
        isLoading = false
    }
}
