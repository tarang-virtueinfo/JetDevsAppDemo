//
//  DefaultLoginValidateRepository.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 12/7/22.
//

import Foundation
import RxSwift

final class DefaultLoginValidateRepository: ValidateRepository {
    enum ValidateRegex: String {
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        case password = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{1,16}$"
    }
    
    func validateEmail(_ email: String) -> ValidationResult {
        guard isValid(from: ValidateRegex.email.rawValue, input: email) else {
            return .failed(message: "Please enter valid email.")
        }
        return .ok
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        guard isValid(from: ValidateRegex.password.rawValue, input: password) else {
            return .failed(message: "Passwords require at least 1 Uppercase, 1 lowercase and 1 number")
        }
        return .ok
    }
    
    func isValid(from regex: String, input: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: input)
    }
}
