//
//  SignUpView.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(UserStore.self) private var userStore
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var selectedRole: String = "normal"
    @State private var stayAnonymous: Bool = false

    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var emailError: Bool = false
    @State private var passwordError: Bool = false
    
    let roles = UserRole.allCases.map { $0.rawValue }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                        .autocapitalization(.words)
                        .textContentType(.givenName)
                    
                    TextField("Last Name", text: $lastName)
                        .autocapitalization(.words)
                        .textContentType(.familyName)
                }
                
                Section(header: Text("Account Details")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .onChange(of: email) { _ in
                            emailError = !Validations.isValidEmail(email)
                        }
                    
                    if emailError {
                        Text("Please enter a valid email address.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .onChange(of: password) { _ in
                            passwordError = !Validations.isValidPassword(password)
                        }
                    if passwordError {
                        Text("should have atleast a number, special char (@,!,#) & atleast a cap letter")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section(header: Text("Role")) {
                    Picker("Select a role", selection: $selectedRole) {
                        ForEach(roles, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.zero)
                }
                
                Section {
                    Toggle("Do you want to stay anonymous?", isOn: $stayAnonymous)
                }
                
                Section {
                    Button(action: {
                        handleSignUp()
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!isFormValid())
                }
            }
            .navigationTitle("Sign up")
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func isFormValid() -> Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty && Validations.isValidEmail(email) && Validations.isValidPassword(password)
    }
    
    private func handleSignUp() {
        if !isFormValid() {
            errorMessage = "Please fill all fields"
            showError = true
            return
        }
        
        Task {
            do {
                let req = UserSignUpRequest(firstName: firstName, lastName: lastName, email: email, password: password, isAnonymous: stayAnonymous, role: selectedRole)
                try await userStore.signup(req: req)
                dismiss()
            } catch {
                errorMessage = "Failed to signup. Please try later"
                showError = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environment(UserStore(httpClient: HTTPClient(), userDefault: .standard))
    }
}
