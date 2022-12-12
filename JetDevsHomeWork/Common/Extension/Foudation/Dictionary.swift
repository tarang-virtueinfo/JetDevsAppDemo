//
//  Dictionary.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 12/8/22.
//

import Foundation

extension Dictionary {
    
    var jsonData: Data? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        let jsonString = String(data: theJSONData, encoding: .utf8)
        return jsonString?.data(using: .utf8, allowLossyConversion: false)
    }
}
