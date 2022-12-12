//
//  LoginUseCase.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 12/7/22.
//

import Foundation
import RxSwift

protocol LoginUseCase {
    
    func login(_ email: String, password: String) -> Observable<LoginResponse>
}

final class DefaultLoginUseCase: LoginUseCase {
    
    private let loginRepository: LoginRepository
    
    init(loginRepository: LoginRepository = DefaultLoginRepository()) {
        self.loginRepository = loginRepository
    }
    
    func login(_ email: String, password: String) -> Observable<LoginResponse> {
        loginRepository.login(email, password: password)
    }
}
