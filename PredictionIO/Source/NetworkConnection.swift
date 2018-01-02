//
//  NetworkConnection.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/1/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation


enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}


public typealias JSON = [String: Any]
typealias HTTPHeaders = [String: String]


class NetworkConnection {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    @discardableResult
    func request(_ url: String, method: HTTPMethod, parameters: JSON? = nil, headers: HTTPHeaders? = nil, completionHandler: @escaping (JSON?, Error?) -> Void) -> URLSessionDataTask? {
        do {
            let request = try URLRequest(url: url, method: method, parameters: parameters, headers: headers)
            let task = session.dataTask(with: request) { data, response, error in
                let error = PIOError.createRequestFailed(error: error)
                guard let data = data else {
                    completionHandler(nil, error)
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON
                    completionHandler(json, error)
                } catch {
                    completionHandler(nil, PIOError.jsonDecodingFailed(error: error))
                }
            }
            task.resume()
            return task
        } catch {
            completionHandler(nil, error)
            return nil
        }
    }
}

extension URLRequest {
    init(url: String, method: HTTPMethod, parameters: JSON? = nil, headers: HTTPHeaders? = nil) throws {
        guard let convertedURL = URL(string: url) else {
            throw PIOError.invalidURL(string: url)
        }
        
        self.init(url: convertedURL)
        httpMethod = method.rawValue
        
        if let headers = headers {
            for (headerField, headerValue) in headers {
                setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        if let parameters = parameters, method == .post {
            // Only POST requests would need a payload in PredictionIO.
            if !JSONSerialization.isValidJSONObject(parameters) {
                throw PIOError.invalidJSON(json: parameters)
            }
            
            do {
                httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw PIOError.jsonEncodingFailed(json: parameters, error: error)
            }
        }
    }
}
