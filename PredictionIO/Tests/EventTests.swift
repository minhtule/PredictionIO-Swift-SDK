//
//  EventTests.swift
//  PredictionIOTests
//
//  Created by Minh Tu Le on 1/2/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import XCTest
@testable import PredictionIO

// swiftlint:disable force_cast force_try
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

        XCTAssertEqual(event.event, "rate")
        XCTAssertEqual(event.entityType, "customer")
        XCTAssertEqual(event.entityID, "c1")
        XCTAssertEqual(event.targetEntityType!, "book")
        XCTAssertEqual(event.targetEntityID!, "b1")
        XCTAssert(event.properties!["rating"] as? Int == 5)
        XCTAssertEqual(event.eventTime, Date(timeIntervalSince1970: 0))
    }

    func testInit_withoutOptionalParameters() {
        let event = Event(
            event: "create",
            entityType: "customer",
            entityID: "c1"
        )

        XCTAssertEqual(event.event, "create")
        XCTAssertEqual(event.entityType, "customer")
        XCTAssertEqual(event.entityID, "c1")
        XCTAssertNil(event.targetEntityType)
        XCTAssertNil(event.targetEntityID)
        XCTAssertNil(event.properties)
        XCTAssertNotNil(event.eventTime)
    }

    func testInitWithJSON() {
        let json: [String: Any] = [
            "event": "rate",
            "entityType": "customer",
            "entityId": "c1",
            "targetEntityType": "book",
            "targetEntityId": "b1",
            "properties": [
                "rating": 5,
                "others": ["foo", "bar"]
            ],
            "eventId": "fake_id",
            "eventTime": "2018-01-13T21:39:45.618Z"
        ]
        let eventTime = Event.dateTimeFormatter.date(from: json["eventTime"] as! String)!
        let event = try! Event(json: json)

        XCTAssertEqual(event.event, json["event"] as! String)
        XCTAssertEqual(event.entityType, json["entityType"] as! String)
        XCTAssertEqual(event.entityID, json["entityId"] as! String)
        XCTAssertEqual(event.targetEntityType!, json["targetEntityType"] as! String)
        XCTAssertEqual(event.targetEntityID!, json["targetEntityId"] as! String)
        XCTAssertTrue(isEqualJSON(event.properties!, json["properties"] as! [String: Any]))
        XCTAssertEqual(event.eventID!, json["eventId"] as! String)
        XCTAssertEqual(event.eventTime, eventTime)
    }

    func testInitiWithJSON_missingEventID_throwsSerializationError() {
        let json: [String: Any] = [
            "event": "rate",
            "entityType": "customer",
            "entityId": "c1",
            "eventTime": "2018-01-13T21:39:45.618Z"
        ]

        XCTAssertThrowsError(try Event(json: json)) { error in
            XCTAssertTrue((error as! PIOError).isDeserializingMissingField("eventId"))
        }
    }

    func testInitiWithJSON_invalidJSONProperties_throwsSerializationError() {
        let json: [String: Any] = [
            "event": "rate",
            "entityType": "customer",
            "entityId": "c1",
            "properties": [
                "foo": [
                    1: "this is not a valid JSON"
                ]
            ],
            "eventId": "fake_id",
            "eventTime": "2018-01-13T21:39:45.618Z"
        ]

        XCTAssertThrowsError(try Event(json: json)) { error in
            XCTAssertTrue((error as! PIOError).isDeserializingInvalidField("properties"))
        }
    }

    func testJSON() {
        let event = Event(
            event: "rate",
            entityType: "customer",
            entityID: "c1",
            targetEntity: (type: "book", id: "b1"),
            properties: [
                "ratings": [5, 4]
            ],
            eventTime: Date(timeIntervalSince1970: 0)
        )

        let expectedJSON: [String: Any] = [
            "event": "rate",
            "entityType": "customer",
            "entityId": "c1",
            "targetEntityType": "book",
            "targetEntityId": "b1",
            "properties": [
                "ratings": [5, 4]
            ],
            "eventTime": "1970-01-01T00:00:00.000Z"
        ]

        XCTAssertTrue(isEqualJSON(event.json, expectedJSON))
    }

    func testValidate_invalidJSONProperties_throwsInvalidEventError() {
        let event = Event(
            event: "rate",
            entityType: "customer",
            entityID: "c1",
            properties: [
                "ratings": [
                    3: "this is an invalid json"
                ]
            ]
        )

        let error = event.validate()! as! PIOError
        XCTAssertTrue(error.isInvalidJSONProperties())
    }

    func testValidate_unsetEventWithEmptyProperties_throwsInvalidEventError() {
        let event = Event(
            event: Event.unsetEvent,
            entityType: "customer",
            entityID: "c1",
            properties: [:]
        )

        let error = event.validate()! as! PIOError
        XCTAssertTrue(error.isUnsetEventWithEmptyProperties())
    }

    private func isEqualJSON(_ left: Any, _ right: Any) -> Bool {
        switch (left, right) {
        // Dictionary
        case let (leftDict as [String: Any], rightDict as [String: Any]):
            if leftDict.count != rightDict.count {
                return false
            }

            for (key, leftValue) in leftDict {
                if rightDict[key] == nil || !isEqualJSON(leftValue, rightDict[key]!) {
                    return false
                }
            }

            return true
        // Array
        case let (leftArray as [Any], rightArray as [Any]):
            if leftArray.count != rightArray.count {
                return false
            }

            for (index, leftElement) in leftArray.enumerated() {
                if !isEqualJSON(leftElement, rightArray[index]) {
                    return false
                }
            }

            return true
        // Bool
        case let (leftBool as Bool, rightBool as Bool):
            return leftBool == rightBool
        // String
        case let (leftString as String, rightString as String):
            return leftString == rightString
        // Number
        case let (leftNumber as NSNumber, rightNumber as NSNumber):
            return leftNumber == rightNumber
        // Otherwise
        default:
            return false
        }
    }
}
