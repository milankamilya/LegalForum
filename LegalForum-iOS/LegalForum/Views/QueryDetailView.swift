//
//  QueryDetailView.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

//
//  QueryDetailView.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import SwiftUI

struct QueryDetailView: View {
    @Environment(QueryStore.self) private var queryStore
    @Environment(UserStore.self) private var userStore
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State var id: String
    @State private var showAssignPopup: Bool = false
    @State private var showAnswerPopup: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let query = queryStore.selectedQuery {
                        
                        // Title
                        Text(query.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                        
                        HStack {
                            // Asked By & date
                            VStack(alignment: .leading) {
                                Text(query.author)
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("\(query.createdAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // category & status
                            VStack(alignment: .trailing) {
                                Text("Category: \(query.category)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Status: \(query.status.rawValue)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Details
                        Text("Details")
                            .font(.headline)
                            .padding(.top, 8)
                        Text(query.detail)
                            .font(.body)
                            .padding(.bottom, 16)
                        
                        // Comments Section
                        if let comments = query.comments, !comments.isEmpty {
                            Text("Comments")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            ForEach(comments, id: \.self) { comment in
                                VStack(alignment: .leading, spacing: 8) {
                                    // Comment Header: Created By and Created At
                                    HStack {
                                        Text(comment.author)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                        Spacer()
                                        Text("\(comment.createdAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // Comment Detail
                                    Text("\(comment.detail)")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                        .background(Color(UIColor.systemBackground).cornerRadius(8))
                                )
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding()
            }
            
            // Fixed Buttons at the Bottom
            HStack {
                
                if let user = userStore.loggedInUser,
                   user.isModarator,
                   let query = queryStore.selectedQuery,
                   query.isAssignable {
                    Button(action: {
                        assignPanelist()
                    }) {
                        Text("Assign panelist")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                if let query = queryStore.selectedQuery,
                   query.isReplyable {
                    Button(action: {
                        replyToQuery()
                    }) {
                        Text("Reply")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground).shadow(radius: 2))
        }
        .navigationTitle("Query Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refresh()
        }
        .sheet(isPresented: $showAssignPopup, onDismiss: {
            refresh()
        }) {
            AssignQueryView()
        }
        .sheet(isPresented: $showAnswerPopup, onDismiss: {
            refresh()
        }) {
            AddAnswerView()
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func refresh() {
        Task {
            do {
                try await queryStore.loadQuery(id)
            } catch {
                errorMessage = "Failed to load query"
                showError = true
            }
        }
    }
    
    private func assignPanelist() {
        showAssignPopup = true
    }
    
    private func replyToQuery() {
        showAnswerPopup = true
    }
}

struct QueryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        QueryDetailView(id: "67e03cb233e678881c8223ff")
            .environment(QueryStore(httpClient: HTTPClient(), userStore: UserStore(httpClient: HTTPClient(), userDefault: .standard)))
            .environment(UserStore(httpClient: HTTPClient(), userDefault: .standard))
    }
}
