//
//  LoginResponse.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 12/10/22.
//

import Foundation

// MARK: - LoginResponse
struct LoginResponse: Codable {
    let result: Int
    let errorMessage: String
    let data: UserInformation

    enum CodingKeys: String, CodingKey {
        case result
        case errorMessage = "error_message"
        case data
    }
}

