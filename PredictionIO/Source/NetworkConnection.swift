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

typealias HTTPHeaders = [String: String]
typealias QueryParams = [String: String]

class NetworkConnection {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    @discardableResult
    func get(url: String, queryParams: QueryParams? = nil, headers: HTTPHeaders? = nil, completionHandler: @escaping (Result<Data, PIOError>) -> Void) -> URLSessionDataTask? {
        return request(url, method: .get, queryParams: queryParams, payload: nil, headers: headers, completionHandler: completionHandler)
    }

    @discardableResult
    func post(url: String, payload: Any?, queryParams: QueryParams? = nil, headers: HTTPHeaders? = nil, completionHandler: @escaping (Result<Data, PIOError>) -> Void) -> URLSessionDataTask? {
        return request(url, method: .post, queryParams: queryParams, payload: payload, headers: headers, completionHandler: completionHandler)
    }

    @discardableResult
    func delete(url: String, queryParams: QueryParams? = nil, headers: HTTPHeaders? = nil, completionHandler: @escaping (Result<Data, PIOError>) -> Void) -> URLSessionDataTask? {
        return request(url, method: .delete, queryParams: queryParams, payload: nil, headers: headers, completionHandler: completionHandler)
    }

    private func request(_ url: String, method: HTTPMethod, queryParams: QueryParams? = nil, payload: Any?, headers: HTTPHeaders? = nil, completionHandler: @escaping (Result<Data, PIOError>) -> Void) -> URLSessionDataTask? {
        do {
            var request = try URLRequest(url: url, method: method, queryParams: queryParams, headers: headers)
            try request.attachJSONPayload(payload: payload)

            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completionHandler(.failure(PIOError.RequestFailureReason.failedError(error)))
                    return
                }

                guard let response = response as? HTTPURLResponse,
                    let data = data
                else {
                    // We should never be here!
                    completionHandler(.failure(PIOError.RequestFailureReason.unknownResponseError()))
                    return
                }

                switch response.statusCode {
                case 200...201:
                    completionHandler(.success(data))
                default:
                    let message: String
                    if
                        let data = try? JSONSerialization.jsonObject(with: data, options: []),
                        let jsonData = data as? [String: Any],
                        let messageValue = jsonData["message"] as? String
                    {
                        message = messageValue
                    } else {
                        message = "-- Cannot parse message from server --"
                    }
                    let error = PIOError.RequestFailureReason.serverFailureError(statusCode: response.statusCode, message: message)
                    completionHandler(.failure(error))
                }
            }
            task.resume()
            return task
        } catch {
            completionHandler(.failure(error as! PIOError)) // swiftlint:disable:this force_cast
            return nil
        }
    }
}

extension URLRequest {
    init(url: String, method: HTTPMethod, queryParams: QueryParams? = nil, payload: Any? = nil, headers: HTTPHeaders? = nil) throws {
        var urlComponent = URLComponents(string: url)

        if let queryParams = queryParams {
            urlComponent?.queryItems = queryParams.map { URLQueryItem(name: $0, value: $1) }
        }

        guard let urlWithQuery = urlComponent?.url else {
            throw PIOError.invalidURL(string: url, queryParams: queryParams)
        }

        self.init(url: urlWithQuery)
        httpMethod = method.rawValue

        headers?.forEach { field, value in
            setValue(value, forHTTPHeaderField: field)
        }
    }

    mutating func attachJSONPayload(payload: Any?) throws {
        if let payload = payload,
            let httpMethod = httpMethod, httpMethod == HTTPMethod.post.rawValue {
            do {
                httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
                setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw PIOError.SerializationFailureReason.failedError(error)
            }
        }
    }
}
