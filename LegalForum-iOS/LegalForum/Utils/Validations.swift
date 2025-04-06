//
//  Validations.swift
//  LegalForum
//
//  Created by Milan Kamilya on 25/03/25.
//

import Foundation

struct Validations {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return email.isEmpty || predicate.evaluate(with: email)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        // Regular expression to check for at least one number, one special character (@, !, #), and one uppercase letter
        let passwordRegex = "^(?=.*[0-9])(?=.*[@!#])(?=.*[A-Z]).{6,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return password.isEmpty || predicate.evaluate(with: password)
    }
}
