//
//  EventTests.swift
//  PredictionIOTests
//
//  Created by Minh Tu Le on 1/2/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import XCTest
import PredictionIO


class EventTests: XCTestCase {
    
    func testInit() {
        let event = Event(
            event: "rate",
            entityType: "customer",
            entityID: "c1",
            targetEntity: (type: "book", id: "b1"),
            properties: ["rating": 5],
            eventTime: Date(timeIntervalSince1970: 0)
        )
        
        XCTAssertEqual(event.event, "rate", "Event name should be \"rate\"")
        XCTAssertEqual(event.entityType, "customer", "Entity type should be \"customer\"")
        XCTAssertEqual(event.entityID, "c1", "Entity ID should be \"c1\"")
        XCTAssertEqual(event.targetEntityType!, "book", "Target entity type should be \"book\"")
        XCTAssertEqual(event.targetEntityID!, "b1", "Target entity ID should be \"rate\"")
        XCTAssert(event.properties!["rating"] as? Int == 5, "Rating should be 5")
        XCTAssertEqual(event.eventTime, Date(timeIntervalSince1970: 0), "Event date should be equal")
    }
    
    func testInitWithoutOptionalParameters() {
        let event = Event(
            event: "create",
            entityType: "customer",
            entityID: "c1"
        )
        
        XCTAssertEqual(event.event, "create", "Event name should be \"create\"")
        XCTAssertEqual(event.entityType, "customer", "Entity type should be \"customer\"")
        XCTAssertEqual(event.entityID, "c1", "Entity ID should be \"c1\"")
        XCTAssertNil(event.targetEntityType, "Target entity type should be nil")
        XCTAssertNil(event.targetEntityID, "Target entity ID should be nil")
        XCTAssertNil(event.properties, "Properties should be nil")
        XCTAssertNotNil(event.eventTime, "Event date should not be nil")
    }
}
