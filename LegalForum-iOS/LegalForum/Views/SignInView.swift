//
//  SignInView.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Email Field
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.headline)
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Password Field
                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.headline)
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Sign In Button
                Button(action: {
                    performSignIn()
                }) {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding(.horizontal)
                
                Spacer()
                
                // Sign Up Option
                VStack {
                    Text("Don't have an account?")
                        .font(.subheadline)
                    NavigationLink("Sign up", destination: SignUpView())
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Sign in")
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func performSignIn() {
        Task {
            do {
                let req = UserSignInRequest(email: email, password: password)
                try await userStore.login(req: req)
                dismiss()
            } catch {
                errorMessage = "Failed to sign in. Please check your credentials."
                showError = true
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        return SignInView()
            .environment(UserStore(httpClient: HTTPClient(), userDefault: .standard))
        
    }
}
