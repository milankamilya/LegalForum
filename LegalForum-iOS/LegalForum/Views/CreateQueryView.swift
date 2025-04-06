//
//  CreateQueryView.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import SwiftUI

struct CreateQueryView: View {
    @Environment(QueryStore.self) private var queryStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var isPublic: Bool = true
    @State private var selectedCategory: String = ""
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    let categories = QueryCategory.allCases.map { $0.rawValue }
    
    var body: some View {
        NavigationView {
            Form {
                // Title Section
                Section(header: Text("Title")) {
                    TextField("Enter query title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Details Section
                Section(header: Text("Details")) {
                    TextEditor(text: $details)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                
                // Public Toggle Section
                Section {
                    Toggle("Do you want it to be displayed to all?", isOn: $isPublic)
                }
                
                // Category Picker Section
                Section(header: Text("Category")) {
                    Picker("Select a category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Submit Button
                Section {
                    Button(action: {
                        handleSubmit()
                    }) {
                        Text("Submit query")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!isFormValid())
                }
            }
            .navigationTitle("Ask your query")
        }
    }
    
    private func isFormValid() -> Bool {
        return !title.isEmpty && !details.isEmpty && !selectedCategory.isEmpty
    }
    
    private func handleSubmit() {
        Task {
            do {
                let req = CreateQueryRequest(title: title, detail: details, category: selectedCategory, isPrivate: !isPublic)
                try await queryStore.createQuery(req)
                dismiss()
            } catch {
                errorMessage = "Failed to load query"
                showError = true
            }
        }
    }
}

struct CreateQueryView_Previews: PreviewProvider {
    static var previews: some View {
        CreateQueryView()
            .environment(QueryStore(httpClient: HTTPClient(), userStore: UserStore(httpClient: HTTPClient(), userDefault: .standard)))
    }
}
