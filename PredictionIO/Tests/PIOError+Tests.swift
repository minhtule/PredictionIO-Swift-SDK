//
//  PIOError+Tests.swift
//  PredictionIOTests
//
//  Created by Minh Tu Le on 1/7/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation
import PredictionIO


extension PIOError {
    
    // Invalid URL
    
    func isInvalidURL(string: String, queryParams: [String: String]?) -> Bool {
        if case let .invalidURL(selfString, selfQueryParams) = self {
            let sameQueryParams: Bool
            if let queryParams = queryParams, let selfQueryParams = selfQueryParams {
                sameQueryParams = queryParams == selfQueryParams
            } else {
                sameQueryParams = queryParams == nil && selfQueryParams == nil
            }
            
            return sameQueryParams && string == selfString
        }
        return false
    }
    
    // Invalid Event
    
    func isInvalidEventID() -> Bool {
        if case let .invalidEvent(reason) = self,
            case PIOError.InvalidEventReason.invalidEventID = reason
        {
            return true
        }
        return false
    }
    
    func isInvalidJSONProperties() -> Bool {
        if case let .invalidEvent(reason) = self,
            case PIOError.InvalidEventReason.invalidJSONProperties = reason
        {
            return true
        }
        return false
    }
    
    func isUnsetEventWithEmptyProperties() -> Bool {
        if case let .invalidEvent(reason) = self,
            case PIOError.InvalidEventReason.unsetEventWithEmptyProperties = reason
        {
            return true
        }
        return false
    }
    
    // Failed Request
    
    func isUnauthorizedRequest() -> Bool {
        if case let .failedRequest(reason) = self,
            case PIOError.RequestFailureReason.unauthorized = reason
        {
            return true
        }
        return false
    }
    
    func isNotFoundRequest() -> Bool {
        if case let .failedRequest(reason) = self,
            case PIOError.RequestFailureReason.notFound = reason
        {
            return true
        }
        return false
    }
    
    func isBadRequest() -> Bool {
        if case let .failedRequest(reason) = self,
            case PIOError.RequestFailureReason.badRequest = reason
        {
            return true
        }
        return false
    }
    
    func isUnknownResponseRequest() -> Bool {
        if case let .failedRequest(reason) = self,
            case PIOError.RequestFailureReason.unknownResponse = reason
        {
            return true
        }
        return false
    }
    
    func isUnknownStatusCodeRequest(statusCode: Int? = nil) -> Bool {
        if case let .failedRequest(reason) = self,
            case let PIOError.RequestFailureReason.unknownStatusCode(myStatusCode) = reason
        {
            if let statusCode = statusCode {
                return statusCode == myStatusCode
            }
            return true
        }
        return false
    }
    
    func isFailedRequest() -> Bool {
        if case let .failedRequest(reason) = self,
            case PIOError.RequestFailureReason.failed = reason
        {
            return true
        }
        return false
    }
    
    // Failed Serialization
    
    func isFailedSerialization() -> Bool {
        if case let .failedSerialization(reason) = self,
            case PIOError.SerializationFailureReason.failed = reason
        {
            return true
        }
        return false
    }
    
    // Failed Deserialization
    
    func isDeserializingUnknownFormat() -> Bool {
        if case let .failedDeserialization(reason) = self,
            case PIOError.DeserializationFailureReason.unknownFormat = reason
        {
            return true
        }
        return false
    }
    
    func isDeserializingMissingField(_ field: String? = nil) -> Bool {
        if case let .failedDeserialization(reason) = self,
            case let PIOError.DeserializationFailureReason.missingField(myMissingField) = reason
        {
            if let field = field {
                return field == myMissingField
            }
            return true
        }
        return false
    }
    
    func isDeserializingInvalidField(_ field: String? = nil) -> Bool {
        if case let .failedDeserialization(reason) = self,
            case let PIOError.DeserializationFailureReason.invalidField(myInvalidField, _) = reason
        {
            if let field = field {
                return field == myInvalidField
            }
            return true
        }
        return false
    }
    
    func isFailedDeserialization() -> Bool {
        if case let .failedDeserialization(reason) = self,
            case PIOError.DeserializationFailureReason.failed = reason
        {
            return true
        }
        return false
    }
}
