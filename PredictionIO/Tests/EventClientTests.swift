//
//  EventClientTests.swift
//  PredictionIOTests
//
//  Created by Minh Tu Le on 1/5/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import XCTest
import PredictionIO


class EventClientTests: XCTestCase {
//    let accessKey = "123"  // Replace with the real app's access key if testing using actual PredictionIO localhost setup.
    let accessKey = "qmakL8SG5lAYkw62-JEOaSAjXCGhM_s__ggGyw_Hm8wSSEJj49x0Qvhmm2TZu5qL"
    var eventClient: EventClient!
    
    override func setUp() {
        super.setUp()
        
        eventClient = EventClient(accessKey: accessKey, baseURL: "http://localhost:7070")
    }
    
    func testCreateEvent() {
        let event = Event(event: "register", entityType: "user", entityID: "foo")
        let expectation = self.expectation(description: "Creating an event in event server")
        
        eventClient.createEvent(event: event) { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    func testGetEvent() {
        let event = Event(event: "register", entityType: "user", entityID: "foo")
        let createEventExpectation = self.expectation(description: "Creating an event in event server")
        var eventID: String?
        
        eventClient.createEvent(event: event) { response, error in
            eventID = response!.eventID
            createEventExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        let getEventExpectation = self.expectation(description: "Getting an event in event server")
        eventClient.getEvent(eventID: eventID!) { createdEvent, error in
            XCTAssertNotNil(createdEvent, "Request should succeed, got \(error!)")
            XCTAssertEqual(event.event, createdEvent!.event)
            
            getEventExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    // Mark: Convenient methods for user entity
    
    func testSetUser() {
        let expectation = self.expectation(description: "Setting properties of a user")
        
        eventClient.setUser(userID: "u1", properties: ["p1": "foo", "p2": "bar"], completionHandler: { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    func testUnsetUser() {
        let expectation = self.expectation(description: "Unsetting properties of a user")
        
        eventClient.unsetUser(userID: "u2", properties: ["p1": NSNull()], completionHandler: { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    func testDeleteUser() {
        let expectation = self.expectation(description: "Unsetting properties of a user")
        
        eventClient.deleteUser(userID: "u4", completionHandler: { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    // Mark: Convenient methods for item entity
    
    func testSetItem() {
        let expectation = self.expectation(description: "Setting properties of an item")
        
        eventClient.setItem(itemID: "i1", properties: ["p1": "foo", "p2": "bar"], completionHandler: { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    func testUnsetItem() {
        let expectation = self.expectation(description: "Unsetting properties of an item")
        
        eventClient.unsetItem(itemID: "i2", properties: ["p1": NSNull()], completionHandler: { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    func testDeleteItem() {
        let expectation = self.expectation(description: "Unsetting properties of an item")
        
        eventClient.deleteItem(itemID: "i4", completionHandler: { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
    
    // MARK: Convenient methods for user action on item
    
    func testRecordAction() {
        let expectation = self.expectation(description: "Record user action on item")
        
        eventClient.recordAction(action: "rate", byUserID: "u1", onItemID: "i1", properties: ["rating": 5], completionHandler: { response, error in
            XCTAssertNotNil(response, "Request should succeed, got \(error!)")
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "\(error!)")
        }
    }
}
