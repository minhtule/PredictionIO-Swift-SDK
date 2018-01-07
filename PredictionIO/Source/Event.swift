//
//  Event.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/6/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation

// MARK: - Event

/**
 An `Event` class that represents a PredictionIO's event  dictionary in
 its REST API.
 */
public struct Event {
    // MARK: Constants
    
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
    
    // MARK: Properties
    
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
    
    /// The event properties.
    ///
    /// **Note:** All properties names starting with "$" and "pio_" are reversed
    /// and shouldn't be used.
    public let properties: [String: Any]?
    
    /// The time of the event.
    public let eventTime: Date
    
    /// The event ID. This value should only be set by the server.
    public let eventID: String?
    
    // MARK: Constructors
    
    /**
     :param: event The event name
     :param: entityType The entity type
     :param: entityID The entity ID
     :param: targetEntity The target entity (type, ID) tuple
     :param: properties The event properties
     :param: eventTime The event time
     */
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

extension Event {
    
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
            let targetEntityID = json["targetEntityId"] as? String
        {
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
    
    var json: [String: Any] {
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
