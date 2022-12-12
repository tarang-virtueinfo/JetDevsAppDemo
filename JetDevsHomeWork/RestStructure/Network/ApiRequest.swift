//
//  ApiRequest.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 12/8/22.
//

import Foundation

struct APIRequest {
    let path: String
    var method = HttpMethod.GET
    var parameters = [String: String]()
}

extension APIRequest {
    
    func toRequest() -> URLRequest {
        let baseURL = baseURL
        let requestFullPath = "\(baseURL)/\(path)"
        let requestURL = URL(string: requestFullPath)!
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.httpBody = parameters.jsonData
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        debugPrint("CURL \(request.cURL(pretty: true))")
        return request
    }
}

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}
