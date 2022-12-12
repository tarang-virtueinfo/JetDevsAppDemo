//
//  DefaultLoginRepository.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 12/7/22.
//

import Foundation
import RxSwift

final class DefaultLoginRepository: LoginRepository {
    
    init() {}
    
    func login(_ email: String, password: String) -> Observable<LoginResponse> {
        let parameters = ["email": email,
                          "password": password]
        let request = APIRequest(path: EnPoints.login.rawValue, method: .POST, parameters: parameters)
        return API.manager.send(apiRequest: request)
    }
}
