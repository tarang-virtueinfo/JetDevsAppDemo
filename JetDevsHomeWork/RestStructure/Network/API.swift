//
//  API.swift
//  JetDevsHomeWork
//
//  Created by Tarang on 12/8/22.
//

import Foundation
import RxSwift

enum ErrorResult: Error {
    case network(string: String)
    case parser(string: String)
    case custom(string: String)
    
    var localizedDescription: String {
        switch self {
        case .network(let value):   return value
        case .parser(let value):    return value
        case .custom(let value):    return value
        }
    }
}

final class API {
    
    static let manager = API()
    
    private init() {}
    
    // create a method for calling api which is return a Observable
    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { observer in
            let task = URLSession.shared.dataTask(with: apiRequest.toRequest()) { (data, response, error) in
                guard let response = response as? HTTPURLResponse, response.isResponseOK() else {
                    observer.onError(ErrorResult.network(string: "An error occur during request. Please try again"))
                    observer.onCompleted()
                    return
                }
                do {
                    print("X-Acc \(response.getXAccessToken())")
                    if response.getXAccessToken() != "" {
                        UserDefaults.standard.set(response.getXAccessToken(), forKey: "X-AccessToken")
                    }
                        
                    let response = try JSONDecoder().decode(T.self, from: data ?? Data())
                    observer.onNext(response)
                } catch {
                    observer.onError(ErrorResult.parser(string: "Invalid response data. Please try again later"))
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

extension HTTPURLResponse {
    func isResponseOK() -> Bool {
        print(self.statusCode)
        return (200...500).contains(self.statusCode)
    }
    func getXAccessToken() -> String {
        print(self.allHeaderFields)
        if let xAuth = self.allHeaderFields["X-Acc"] as? String {
           // use X-Acc here
            return xAuth
        }

        return ""
    }
    
}
