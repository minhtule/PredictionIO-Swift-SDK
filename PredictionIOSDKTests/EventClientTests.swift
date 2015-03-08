//
//  EventClientTests.swift
//  PredictionIOSDK
//
//  Created by Minh Tu Le on 3/5/15.
//  Copyright (c) 2015 PredictionIO. All rights reserved.
//

import XCTest
import PredictionIOSDK

class EventClientTests: XCTestCase {
    let accessKey = "123"  // Replace with the real app's access key if testing using actual PredictionIO localhost setup.
    var eventClient: EventClient!
    
    override func setUp() {
        super.setUp()
        
        eventClient = EventClient(accessKey: accessKey, baseURL: "http://localhost:7070")
    }
    

    func testCreateEvent() {
        let event = Event(event: "register", entityType: "user", entityID: "foo")
        let expectation = expectationWithDescription("Creating an event in event server")

        eventClient.createEvent(event) { (_, response, _, _) -> Void in
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 201, "Creating an event should succeed with 201 code")
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    // Mark: Convenient methods for user entity
    
    func testSetUser() {
        let expectation = expectationWithDescription("Setting properties of a user")
        
        eventClient.setUser("u1", properties: ["p1": "foo", "p2": "bar"], completionHandler: { (_, response, _, _) -> Void in
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 201, "Setting a user's properties should succeed with 201 code")

            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testUnsetUser() {
        let expectation = expectationWithDescription("Unsetting properties of a user")
        
        eventClient.unsetUser("u2", properties: ["p1": NSNull()], completionHandler: { (_, response, _, _) -> Void in
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 201, "Setting a user's properties should succeed with 201 code")

            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDeleteUser() {
        let expectation = expectationWithDescription("Unsetting properties of a user")
        
        eventClient.deleteUser("u4", completionHandler: { (_, response, _, _) -> Void in
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 201, "Setting a user's properties should succeed with 201 code")

            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    // Mark: Convenient methods for item entity
    
    func testSetItem() {
        let expectation = expectationWithDescription("Setting properties of an item")
        
        eventClient.setItem("i1", properties: ["p1": "foo", "p2": "bar"], completionHandler: { (_, response, _, _) -> Void in
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 201, "Setting an item's properties should succeed with 201 code")

            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testUnsetItem() {
        let expectation = expectationWithDescription("Unsetting properties of an item")
        
        eventClient.unsetItem("i2", properties: ["p1": NSNull()], completionHandler: { (_, response, _, _) -> Void in
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 201, "Setting an item's properties should succeed with 201 code")

            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    func testDeleteItem() {
        let expectation = expectationWithDescription("Unsetting properties of an item")
        
        eventClient.deleteItem("i4", completionHandler: { (_, response, _, _) -> Void in
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 201, "Setting an item's properties should succeed with 201 code")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
    
    // MARK: Convenient methods for user action on item
    
    func testRecordAction() {
        let expectation = expectationWithDescription("Record user action on item")
        
        eventClient.recordAction("rate", byUserID: "u1", itemID: "i1", properties: ["rating": 5], completionHandler: { (_, response, _, _) -> Void in
            XCTAssertNotNil(response, "Request should succeed")
            XCTAssert(response?.statusCode == 201, "Record an action should succeed with 201 code")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "\(error)")
        }
    }
}
