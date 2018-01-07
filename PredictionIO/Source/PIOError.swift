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
    case invalidEvent(reason: InvalidEventReason)
    case failedRequest(reason: RequestFailureReason)
    case failedSerialization(reason: SerializationFailureReason)
    case failedDeserialization(reason: DeserializationFailureReason)
    
    public enum InvalidEventReason {
        case invalidEventID
        case invalidJSONProperties
        case unsetEventWithEmptyProperties
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
        case failed(error: Error)
    }
    
    public enum DeserializationFailureReason {
        case unknownFormat
        case missingField(String)
        case invalidField(String, value: Any?)
        case failed(error: Error)
    }
}

extension PIOError.InvalidEventReason {
    static func invalidEventIDError() -> PIOError {
        return PIOError.invalidEvent(reason: .invalidEventID)
    }
    
    static func invalidJSONPropertiesError() -> PIOError {
        return PIOError.invalidEvent(reason: .invalidJSONProperties)
    }
    
    static func unsetEventWithEmptyPropertiesError() -> PIOError {
        return PIOError.invalidEvent(reason: .unsetEventWithEmptyProperties)
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
    static func failedError(_ error: Error) -> PIOError {
        return PIOError.failedSerialization(reason: .failed(error: error))
    }
}

extension PIOError.DeserializationFailureReason {
    static func unknownFormatError() -> PIOError {
        return PIOError.failedDeserialization(reason: .unknownFormat)
    }
    
    static func missingFieldError(field: String) -> PIOError {
        return PIOError.failedDeserialization(reason: .missingField(field))
    }
    
    static func invalidFieldError(field: String, value: Any?) -> PIOError {
        return PIOError.failedDeserialization(reason: .invalidField(field, value: value))
    }
    
    static func failedError(_ error: Error) -> PIOError {
        return PIOError.failedDeserialization(reason: .failed(error: error))
    }
}
