//
//  AddAnswerView.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import SwiftUI

struct AddAnswerView: View {
    @Environment(QueryStore.self) private var queryStore
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""

    @State private var answerText: String = ""

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
                
                // Answer TextEditor Section
                Text("Your Answer:")
                    .font(.headline)
                TextEditor(text: $answerText)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.bottom, 16)
                
                Spacer()
                
                // Submit Button
                Button(action: submitAnswer) {
                    Text("Submit Answer")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(answerText.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(answerText.isEmpty) // Disable button if the answer is empty
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Add Answer")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func submitAnswer() {
        guard let queryId = queryStore.selectedQuery?.id else {
            return
        }
        Task {
            do {
                let req = AnswerQueryRequest(id: queryId, answer: answerText)
                try await queryStore.answerToQuery(req)
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

struct AddAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        AddAnswerView()
            .environment(QueryStore(httpClient: HTTPClient(), userStore: UserStore(httpClient: HTTPClient(), userDefault: .standard)))
    }
}
