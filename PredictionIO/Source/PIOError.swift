//
//  Error.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/2/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation

/// `PIOError` is the error type returned by PredictionIO.
public enum PIOError: Error {
    /// Returned when failing to convert a string and optionally a query params
    /// dictionary to a valid `URL`.
    case invalidURL(string: String, queryParams: [String: String]?)
    /// Returned when an event is found invalid
    case invalidEvent(reason: InvalidEventReason)
    /// Returned when a request fails. It could be due to network error, backend error
    /// or unknown response format.
    case failedRequest(reason: RequestFailureReason)
    /// Returned when failing to serialize an object to a JSON.
    case failedSerialization(reason: SerializationFailureReason)
    /// Returned when failing to deserialize a JSON to an object.
    case failedDeserialization(reason: DeserializationFailureReason)

    // MARK: - Failure reasons

    /// The underlying reason the event is invalid.
    public enum InvalidEventReason {
        /// The `Event.eventID` cannot be URL-quoted.
        case invalidEventID
        /// The `Event.properties` is not a valid JSON dictionary.
        case invalidJSONProperties
        /// An `$unset` event has empty or nil `Event.properties`.
        case unsetEventWithEmptyProperties
    }

    /// The underlying reason the request fails.
    public enum RequestFailureReason {
        /// Server returns a non-successful status code.
        ///   - 400: bad request e.g. invalid date format
        ///   - 401: unauthorized
        ///   - 404: resource not found
        ///   - 500: internal error
        ///
        /// The server would also return a "message" field in the
        /// response's JSON data.
        case serverFailure(statusCode: Int, message: String)
        /// Unknown response format returned by the server.
        case unknownResponse
        /// Failure due to network or any other error.
        case failed(error: Error)
    }

    /// The underlying reason the serialization fails.
    public enum SerializationFailureReason {
        /// Failure due to some error.
        case failed(error: Error)
    }

    /// The underlying reason the deserialization fails.
    public enum DeserializationFailureReason {
        /// The format is unknown.
        case unknownFormat
        /// There is a missing field.
        case missingField(String)
        /// There is an invalid field.
        case invalidField(String, value: Any?)
        /// Failure due to some other error.
        case failed(error: Error)
    }
}

// MARK: - Convenience factory methods to create a PIOError

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
    static func serverFailureError(statusCode: Int, message: String) -> PIOError {
        return PIOError.failedRequest(reason: .serverFailure(statusCode: statusCode, message: message))
    }

    static func unknownResponseError() -> PIOError {
        return PIOError.failedRequest(reason: .unknownResponse)
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
