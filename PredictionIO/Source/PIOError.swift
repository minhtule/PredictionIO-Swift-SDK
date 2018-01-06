//
//  Error.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/2/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation


public enum PIOError: Error {
    case invalidURL(string: String, queryParams: [String: String]?)
    case invalidEventID(id: String)
    case invalidEvent(reason: InvalidEventReason)
    case failedRequest(reason: RequestFailureReason)
    case failedSerialization(reason: SerializationFailureReason)
    case failedDeserialization(reason: DeserializationFailureReason)
    
    public enum InvalidEventReason {
        case unsetEventWithEmptyProperties
        case invalidJSONProperties
    }
    
    public enum RequestFailureReason {
        case unauthorized  // Server return 401
        case notFound  // Server returns 404
        case badRequest  // Server returns 400 e.g. fail to parse the JSON event
        case unknownResponse
        case unknownStatusCode(Int)
        case failed(error: Error)
    }
    
    public enum SerializationFailureReason {
        case missingField(String)
        case invalidField(String, value: Any?)
        case failed(error: Error)
    }
    
    public enum DeserializationFailureReason {
        case failed(error: Error)
    }
}

extension PIOError.InvalidEventReason {
    static func unsetEventWithEmptyPropertiesError() -> PIOError {
        return PIOError.invalidEvent(reason: .unsetEventWithEmptyProperties)
    }
    
    static func invalidJSONPropertiesError() -> PIOError {
        return PIOError.invalidEvent(reason: .invalidJSONProperties)
    }
}

extension PIOError.RequestFailureReason {
    static func unauthorizedError() -> PIOError {
        return PIOError.failedRequest(reason: .unauthorized)
    }
    
    static func notFoundError() -> PIOError {
        return PIOError.failedRequest(reason: .notFound)
    }
    
    static func badRequestError() -> PIOError {
        return PIOError.failedRequest(reason: .badRequest)
    }
    
    static func unknownResponseError() -> PIOError {
        return PIOError.failedRequest(reason: .unknownResponse)
    }
    
    static func unknownStatusCodeError(statusCode: Int) -> PIOError {
        return PIOError.failedRequest(reason: .unknownStatusCode(statusCode))
    }
    
    static func failedError(_ error: Error) -> PIOError {
        return PIOError.failedRequest(reason: .failed(error: error))
    }
}

extension PIOError.SerializationFailureReason {
    static func missingFieldError(field: String) -> PIOError {
        return PIOError.failedSerialization(reason: .missingField(field))
    }
    
    static func invalidFieldError(field: String, value: Any?) -> PIOError {
        return PIOError.failedSerialization(reason: .invalidField(field, value: value))
    }
    
    static func failedError(_ error: Error) -> PIOError {
        return PIOError.failedSerialization(reason: .failed(error: error))
    }
}

extension PIOError.DeserializationFailureReason {
    static func failedError(_ error: Error) -> PIOError {
        return PIOError.failedDeserialization(reason: .failed(error: error))
    }
}
