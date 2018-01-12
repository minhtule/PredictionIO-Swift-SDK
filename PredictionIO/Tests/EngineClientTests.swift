//
//  EngineClientTests.swift
//  PredictionIOTests
//
//  Created by Minh Tu Le on 1/8/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import XCTest
import PredictionIO

class EngineClientTests: XCTestCase {
    var engineClient: EngineClient!

    override func setUp() {
        super.setUp()

        engineClient = EngineClient(baseURL: "http://localhost:8000")
    }

    func testSendQuery() {
        let expectation = self.expectation(description: "Sending query")

        engineClient.sendQuery(["user": "1"]) { result in
            XCTAssertTrue(result.isSuccess, "Request should succeed, got \(result.error!)")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }

    func testSendQueryWithResponseType() {
        // This test expects the engine server to return a JSON response that
        // has same response format as the recommendation/similar product engine
        // template e.g.
        //
        // {
        //     "itemScores": [
        //         {
        //             "item": "39",
        //             "score": 6.177719297832409
        //         },
        //         {
        //             "item": "79",
        //             "score": 5.931687319083594
        //         }
        //     ]
        // }
        //
        let expectation = self.expectation(description: "Sending query")

        engineClient.sendQuery(["user": "1"], responseType: SimilarProductResponse.self) { result in
            XCTAssertTrue(result.isSuccess, "Request should succeed, got \(result.error!)")

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
}

private struct SimilarProductResponse: Decodable {
    struct ItemScore: Decodable {
        let itemID: String
        let score: Double

        enum CodingKeys: String, CodingKey {
            case itemID = "item"
            case score
        }
    }

    let itemScores: [ItemScore]
}
