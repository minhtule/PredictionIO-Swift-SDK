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
        
        engineClient.sendQuery(["user": "1"]) { data, error in
            XCTAssertNotNil(data, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    func testSendQueryWithResponseType() {
        let expectation = self.expectation(description: "Sending query")
        
        engineClient.sendQuery(["user": "1"], responseType: SimilarProductResponse.self) { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    private struct SimilarProductResponse: Decodable {
        struct ItemScore: Decodable {
            let item: Int
            let score: Double
        }
        
        let itemScores: [ItemScore]
    }
}
