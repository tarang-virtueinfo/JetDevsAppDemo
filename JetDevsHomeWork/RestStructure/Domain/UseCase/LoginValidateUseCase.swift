//
//  ValidateUseCase.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 12/7/22.
//

import Foundation
import RxSwift

enum ValidationResult {
    
    case ok
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    
    var isValid: Bool {
        switch self {
        case .ok: return true
        default: return false
        }
    }
    
    var errorMessage: String {
        switch self {
        case .failed(message: let message): return message
        default: return ""
        }
    }
}

protocol LoginValidateUseCase {
    
    func validateEmail(_ email: String) -> ValidationResult
    func validatePassword(_ password: String) -> ValidationResult
}

final class DefaultLoginValidateUseCase: LoginValidateUseCase {
    
    private let repository: ValidateRepository
    
    init(repository: ValidateRepository = DefaultLoginValidateRepository()) {
        self.repository = repository
    }
    
    func validateEmail(_ email: String) -> ValidationResult {
        repository.validateEmail(email)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        repository.validatePassword(password)
    }
}
