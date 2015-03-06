//
//  EngineClientTests.swift
//  PredictionIOSDK
//
//  Created by Minh Tu Le on 3/5/15.
//  Copyright (c) 2015 PredictionIO. All rights reserved.
//

import XCTest

class EngineClientTests: XCTestCase {
    var engineClient: EngineClient!
    
    override func setUp() {
        super.setUp()
        
        engineClient = EngineClient(baseURL: "http://localhost:8000")
    }

    func testSendQuery() {
        let expectation = expectationWithDescription("Sending query to engine server")
        
        engineClient.sendQuery(["user": "1"]) { (_, response, _, _) -> Void in
            expectation.fulfill()
            
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 200, "Sending query should succeed with 200 code")
        }
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
}
