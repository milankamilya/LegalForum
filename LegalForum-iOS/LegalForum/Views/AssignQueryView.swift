//
//  AssignQueryView.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import SwiftUI

struct AssignQueryView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(QueryStore.self) private var queryStore
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    @State private var selectedPanelist: User?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Query Title Section
                if let query = queryStore.selectedQuery {
                    
                    // Title
                    Text(query.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                }
                
                // Panelist List Section
                Text("Select a Panelist:")
                    .font(.headline)
                List(userStore.users, id: \.id) { panelist in
                    HStack {
                        Text(panelist.fullName)
                            .font(.body)
                        Spacer()
                        if selectedPanelist?.id == panelist.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPanelist = panelist
                    }
                }
                
                Spacer()
                
                // Assign Button
                Button(action: {
                    assignQuery()
                }) {
                    Text("Assign")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedPanelist == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(selectedPanelist == nil) // Disable button if no panelist is selected
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Assign Query")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            Task {
                await fetchPanelist()
            }
        }
    }
    
    private func fetchPanelist() async {
        do {
            let req = UserListRequest(role: UserRole.panelist.rawValue)
            try await userStore.list(req: req)
        } catch {
            print(error)
            alertTitle = "Error"
            alertMessage = "Failed to refresh panelist"
            showAlert = true
        }
    }
    
    private func assignQuery() {
        guard let queryId = queryStore.selectedQuery?.id,
              let userId = selectedPanelist?.id else {
            return
        }
        Task {
            do {
                let req = AssignQueryRequest(id: queryId, panelist: userId)
                try await queryStore.assignQuery(req)
                dismiss()
            } catch {
                print(error)
                alertTitle = "Error"
                alertMessage = "Failed to assign panelist. Please try again later"
                showAlert = true
            }
        }
    }
}

struct AssignQueryView_Previews: PreviewProvider {
    static var previews: some View {
        AssignQueryView()
            .environment(QueryStore(httpClient: HTTPClient(), userStore: UserStore(httpClient: HTTPClient(), userDefault: .standard)))
            .environment(UserStore(httpClient: HTTPClient(), userDefault: .standard))
    }
}
