//
//  Event.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/6/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation

/// The `Event` struct represents an event dictionary in the REST API
/// to a PredictionIO's event server.
public struct Event {
    // MARK: - Constants

    /// Reversed set event name.
    public static let setEvent = "$set"

    /// Reversed unset event name.
    public static let unsetEvent = "$unset"

    /// Reversed delete event name.
    public static let deleteEvent = "$delete"

    /// Predefined user entity type.
    public static let userEntityType = "user"

    /// Predefined item entity type.
    public static let itemEntityType = "item"

    // MARK: - Properties

    /// The event name e.g. "sign-up", "rate", "view".
    ///
    /// **Note:** All event names starting with "$" and "pio_" are reversed
    /// and shouldn't be used as your custom event (e.g. "$set").
    public let event: String

    /// The entity type. It is the namespace of the `entityID` and analogous
    /// to the table name of a relational database. The `entityID` must be
    /// unique within the same `entityType`.
    ///
    /// **Note:** All entityType names starting with "$" and "pio_" are reversed
    /// and shouldn't be used.
    public let entityType: String

    /// The entity ID. `entityType-entityID` becomes the unique identifier
    /// of the entity.
    public let entityID: String

    /// The target entity type.
    ///
    /// **Note:** All targetEntityType names starting with "$" and "pio_" are reversed
    /// and shouldn't be used.
    public let targetEntityType: String?

    /// The target entity ID.
    public let targetEntityID: String?

    /// The event properties. It should be a valid JSON dictionary.
    ///
    /// **Note:** All properties names starting with "$" and "pio_" are reversed
    /// and shouldn't be used.
    public let properties: [String: Any]?

    /// The time of the event.
    public let eventTime: Date

    /// The event ID. This value should only be set by the server.
    public let eventID: String?

    // MARK: - Initialization

    /// Creates an event struct.
    ///
    /// - parameter event: The event name.
    /// - parameter entityType: The entity type.
    /// - parameter entityID: The entity ID.
    /// - parameter targetEntity: The target entity (type, ID) tuple.
    /// - parameter properties: The event properties in JSON dictionary.
    /// - parameter eventTime: The event time.
    ///
    /// - returns: The new Event instance.
    public init(event: String, entityType: String, entityID: String, targetEntity: (type: String, id: String)? = nil, properties: [String: Any]? = nil, eventTime: Date = Date()) {
        self.event = event
        self.entityType = entityType
        self.entityID = entityID

        if let targetEntity = targetEntity {
            self.targetEntityType = targetEntity.type
            self.targetEntityID = targetEntity.id
        } else {
            self.targetEntityType = nil
            self.targetEntityID = nil
        }

        self.properties = properties
        self.eventTime = eventTime
        self.eventID = nil
    }

    // MARK: - Validation

    /// Validates an event against the following rules:
    ///   - `properties` must be a valid JSON dictionary.
    ///   - An `$unset` event must not have an empty or nil `properties`.
    ///
    /// - returns: A `PIOError.invalidEvent` error if the validation fails. Otherwise, returns nil.
    public func validate() -> Error? {
        if let properties = properties, !JSONSerialization.isValidJSONObject(properties) {
            return PIOError.InvalidEventReason.invalidJSONPropertiesError()
        }

        if event == Event.unsetEvent && (properties == nil || properties!.isEmpty == true) {
            return PIOError.InvalidEventReason.unsetEventWithEmptyPropertiesError()
        }

        return nil
    }
}

// MARK: -

extension Event {
    // MARK: - JSON Serialization and Deserialization

    /// Creates an event from a JSON dictionary.
    ///
    /// - parameters json: The JSON dictionary.
    ///
    /// - throws: A `PIOError.failedDeserialization` error if deserialization fails.
    ///
    /// - returns: The new Event instance.
    public init(json: [String: Any]) throws {
        guard let event = json["event"] as? String else {
            throw PIOError.DeserializationFailureReason.missingFieldError(field: "event")
        }

        guard let eventID = json["eventId"] as? String else {
            throw PIOError.DeserializationFailureReason.missingFieldError(field: "eventId")
        }

        guard let entityType = json["entityType"] as? String else {
            throw PIOError.DeserializationFailureReason.missingFieldError(field: "entityType")
        }

        guard let entityID = json["entityId"] as? String else {
            throw PIOError.DeserializationFailureReason.missingFieldError(field: "entityId")
        }

        guard let et = json["eventTime"] as? String else {
            throw PIOError.DeserializationFailureReason.missingFieldError(field: "eventTime")
        }

        guard let eventTime = Event.dateTimeFormatter.date(from: et) else {
            throw PIOError.DeserializationFailureReason.missingFieldError(field: "eventTime")
        }

        let properties = json["properties"] as? [String: Any]

        if let properties = properties, !JSONSerialization.isValidJSONObject(properties) {
            throw PIOError.DeserializationFailureReason.invalidFieldError(field: "properties", value: properties)
        }

        self.event = event
        self.entityType = entityType
        self.entityID = entityID

        if let targetEntityType = json["targetEntityType"] as? String,
            let targetEntityID = json["targetEntityId"] as? String {
            self.targetEntityType = targetEntityType
            self.targetEntityID = targetEntityID
        } else {
            self.targetEntityType = nil
            self.targetEntityID = nil
        }

        self.properties = properties
        self.eventTime = eventTime
        self.eventID = eventID
    }

    /// Returns a JSON dictionary representing the event.
    ///
    /// - returns: The JSON dictionary.
    public var json: [String: Any] {
        var json: [String: Any] = [
            "event": event,
            "entityType": entityType,
            "entityId": entityID,
            "eventTime": Event.dateTimeFormatter.string(from: eventTime)
        ]

        if let targetEntityType = targetEntityType, let targetEntityID = targetEntityID {
            json["targetEntityType"] = targetEntityType
            json["targetEntityId"] = targetEntityID
        }

        if let properties = properties {
            json["properties"] = properties
        }

        return json
    }

    static let dateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()
}
