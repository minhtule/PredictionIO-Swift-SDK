//
//  ResultTests.swift
//  PredictionIO iOS Tests
//
//  Created by Minh Tu Le on 1/12/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import XCTest
@testable import PredictionIO

// swiftlint:disable force_cast
class ResultTests: XCTestCase {
    let error = PIOError.RequestFailureReason.unauthorizedError()

    // MARK: - isSuccess

    func testIsSuccess_whenSuccess_returnsTrue() {
        let result = Result.success(3)

        XCTAssertTrue(result.isSuccess)
    }

    func testIsSuccess_whenFailure_returnsFalse() {
        let result = Result<Int>.failure(error)

        XCTAssertFalse(result.isSuccess)
    }

    // MARK: - isFailure

    func testIsFailure_whenSuccess_returnsFalse() {
        let result = Result.success(3)

        XCTAssertFalse(result.isFailure)
    }

    func testIsFailure_whenFailure_returnsTrue() {
        let result = Result<Int>.failure(error)

        XCTAssertTrue(result.isFailure)
    }

    // MARK: - value

    func testValue_whenSuccess_returnsValue() {
        let result = Result.success(3)

        XCTAssertEqual(result.value, 3)
    }

    func testValue_whenFailure_returnsNil() {
        let result = Result<Int>.failure(error)

        XCTAssertNil(result.value)
    }

    // MARK: - error

    func testError_whenSuccess_returnsNil() {
        let result = Result.success(3)

        XCTAssertNil(result.error)
    }

    func testError_whenFailure_returnsError() {
        let result = Result<Int>.failure(error)

        XCTAssertTrue((result.error as! PIOError).isUnauthorizedRequest())
    }

    // MARK: - map

    func testMap_whenSuccess_transformsValue() {
        let result = Result.success(3)
        let newResult = result.map { $0 * 2 }

        XCTAssertEqual(newResult.value, 6)
    }

    func testMap_whenError_keepsError() {
        let result = Result<Int>.failure(error)
        let newResult = result.map { $0 * 2 }

        XCTAssertTrue((newResult.error as! PIOError).isUnauthorizedRequest())
    }

    // MARK: - flatMap

    func testFlatMap_whenSuccess_transformsValue() {
        let result = Result.success(3)
        let newResult = result.flatMap { Result.success($0 * 10) }

        XCTAssertEqual(newResult.value, 30)
    }

    func testFlatMap_whenError_keepsError() {
        let result = Result<Int>.failure(error)
        let newResult = result.flatMap { Result.success($0 * 10) }

        XCTAssertTrue((newResult.error as! PIOError).isUnauthorizedRequest())
    }

    // MARK: - debugDescription

    func testDebugDescription() {
        let result = Result.success(3)

        XCTAssertEqual(result.debugDescription, "Success: 3")
    }
}
