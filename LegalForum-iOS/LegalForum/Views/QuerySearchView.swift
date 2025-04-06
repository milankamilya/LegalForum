//
//  QuerySearchView.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import SwiftUI

struct QuerySearchView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(QueryStore.self) private var queryStore
    @State var search: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    @State private var showLoginPopup: Bool = false
    @State private var showCreateQueryPopup: Bool = false
    
    var body: some View {
        VStack {
            // Add a search bar
            TextField("Search queries...", text: $search)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onSubmit {
                    performSearch()
                }
            
            // Display the list of queries
            List(queryStore.queries) { query in
                NavigationLink {
                    QueryDetailView(id: query.id)
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: query.status.image)
                            .frame(minWidth: 40,maxHeight: 40)
                        
                        VStack(alignment: .leading) {
                            Text(query.title)
                                .font(.title3)
                            HStack(alignment: .center) {
                                Text(query.author)
                                    .font(.callout)
                                Spacer()
                                Text(query.createdAt, format: Date.FormatStyle(date: .abbreviated))
                                    .font(.caption)
                            }
                            
                        }
                    }
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 8))
                }
            }
            .refreshable {
                await refreshQueries()
            }
        }
        .onAppear {
            Task {
                await refreshQueries()
            }
        }
        .navigationTitle("Legal Forum")
        .toolbar {
            // Left navigation bar item
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onProfileTapped) {
                    Image(systemName: "person.circle")
                }
            }
            
            // Right navigation bar item
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onAddQueryTapped) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showLoginPopup, onDismiss: {
            Task {
                await refreshQueries()
            }
        }) {
            SignInView()
        }
        .sheet(isPresented: $showCreateQueryPopup, onDismiss: {
            Task {
                await refreshQueries()
            }
        }) {
            CreateQueryView()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func filteredQueries(
        items: [Query],
        searchText: String,
        tokens: [QueryCategory]
    ) -> [Query] {
        guard !searchText.isEmpty || !tokens.isEmpty else { return items }
        return items.filter { item in
            let searchableText = "\(item.title) \(item.detail) \(item.category)"
            return searchableText.lowercased().contains(searchText.lowercased()) ||
            tokens.map({ $0.rawValue }).contains(item.category.rawValue.lowercased())
        }
    }
    
    private func refreshQueries() async {
        do {
            let req = QuerySearchRequest(search: search)
            try await queryStore.loadQueries(req)
        } catch {
            print(error)
            alertTitle = "Error"
            alertMessage = "Failed to refresh queries"
            showAlert = true
        }
    }
    
    private func onProfileTapped() {
        if userStore.loggedInUser == nil {
            showLoginPopup = true
        } else {
            Task {
                do {
                    try await userStore.logout()
                    
                    alertTitle = "Logging out"
                    alertMessage = "You have successfully logged out"
                    showAlert = true
                    await refreshQueries()
                } catch {
                    print(error)
                    alertTitle = "Error"
                    alertMessage = "Failed to load profile"
                    showAlert = true
                }
            }
        }
    }
    
    private func onAddQueryTapped() {
        if userStore.loggedInUser == nil {
            alertTitle = "Please sign in first"
            alertMessage = "To add a query, you need to sign in first"
            showAlert = true
        } else {
            showCreateQueryPopup = true
        }
    }
    
    private func performSearch() {
        Task {
            do {
                let req = QuerySearchRequest(search: search)
                try await queryStore.loadQueries(req)
            } catch {
                print(error)
                alertTitle = "Error"
                alertMessage = "Failed to load queries"
                showAlert = true
            }
        }
    }
}
