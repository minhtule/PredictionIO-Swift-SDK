//
//  Result.swift
//  PredictionIO iOS
//
//  Created by Minh Tu Le on 1/12/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation

/// Used to represent if a request including post-processsing is successful
/// or encounters an error.
public enum Result<Value> {
    /// Success state with a value
    case success(Value)
    /// Failure state with an error
    case failure(Error)

    // MARK: - Inspecting a result

    /// Returns `true` if the result is a success. Otherwise, returns `false`.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure. Otherwise, returns `false`.
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the value if the result is a success. Otherwise, returns `nil`.
    public var value: Value? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the error if the result is a failure. Otherwise, returns `nil`.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension Result: CustomDebugStringConvertible {
    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        var result: String
        switch self {
        case let .success(value):
            result = "Success: "
            debugPrint(value, terminator: "", to: &result)
        case let .failure(error):
            result = "Failure: "
            debugPrint(error, terminator: "", to: &result)
        }
        return result
    }
}

// MARK: -

public extension Result {

    // MARK: - Transforming a result

    /// Evaluates the given closure when this `Result` is a success, passing the
    /// value as a parameter.
    ///
    /// Use the `map` method with a closure that returns a value. For example:
    ///
    ///     let result = Result.success(3)
    ///     result.map { $0 * $0 }
    ///     print(result)
    ///     // success(6)
    ///
    /// - parameter transform: A closure that takes the successful value
    ///   of the instance.
    /// - returns: The result of the given closure. If this instance is a failure,
    ///   returns the failure.
    func map<T>(_ transform: (Value) -> T) -> Result<T> {
        switch self {
        case let .success(value):
            return .success(transform(value))
        case let .failure(error):
            return .failure(error)
        }
    }

    /// Evaluates the given closure when this `Result` is a success, passing the
    /// value as a parameter.
    ///
    /// Use the `flatMap` method with a closure that returns a `Result` value. For example:
    ///
    ///     let result = Result.success(4)
    ///     result.flatMap { value in
    ///         if value % 2 == 0 {
    ///             return .success(value * value)
    ///         } else {
    ///             return .failure(error)
    ///         }
    ///     }
    ///     print(result)
    ///     // success(16)
    ///
    /// - parameter transform: A closure that takes the successful value
    ///   of the instance.
    /// - returns: The result of the given closure. If this instance is a failure,
    ///   returns the failure.
    func flatMap<T>(_ transform: (Value) -> Result<T>) -> Result<T> {
        switch self {
        case let .success(value):
            return transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }
}
