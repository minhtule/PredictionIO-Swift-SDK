//
//  PredictionIO.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/1/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation


// MARK: - Event

/**
 An `Event` class that represents a PredictionIO's event JSON dictionary in
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
    public var event: String
    
    /// The entity type. It is the namespace of the `entityID` and analogous
    /// to the table name of a relational database. The `entityID` must be
    /// unique within the same `entityType`.
    ///
    /// **Note:** All entityType names starting with "$" and "pio_" are reversed
    /// and shouldn't be used.
    public var entityType: String
    
    /// The entity ID. `entityType-entityID` becomes the unique identifier
    /// of the entity.
    public var entityID: String
    
    /// The target entity type.
    ///
    /// **Note:** All targetEntityType names starting with "$" and "pio_" are reversed
    /// and shouldn't be used.
    public var targetEntityType: String?
    
    /// The target entity ID.
    public var targetEntityID: String?
    
    /// The event properties.
    ///
    /// **Note:** All properties names starting with "$" and "pio_" are reversed
    /// and shouldn't be used.
    public var properties: JSON?
    
    /// The time of the event.
    public var eventTime: Date
    
    // MARK: Constructors
    
    /**
     :param: event The event name
     :param: entityType The entity type
     :param: entityID The entity ID
     :param: targetEntityType The target entity type
     :param: targetEntityID The target entity ID
     :param: properties The event properties
     :param: eventTime The event time
     */
    public init(event: String, entityType: String, entityID: String, targetEntityType: String? = nil, targetEntityID: String? = nil, properties: JSON? = nil, eventTime: Date = Date()) {
        self.event = event
        self.entityType = entityType
        self.entityID = entityID
        self.targetEntityType = targetEntityType
        self.targetEntityID = targetEntityID
        self.properties = properties
        self.eventTime = eventTime
    }
    
    // MARK: Helpers
    
    func toJSON() -> JSON {
        var json: JSON = [
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
    
    private static let dateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()
}


public class BaseClient {
    let baseURL: String
    let networkConnection: NetworkConnection
    
    init(baseURL: String, timeout: TimeInterval) {
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration)
        networkConnection = NetworkConnection(session: session)
    }
}


public class EventClient: BaseClient {
    let accessKey: String
    
    public init(accessKey: String, baseURL: String = "http://localhost:7070", timout: TimeInterval = 5) {
        self.accessKey = accessKey
        super.init(baseURL: baseURL, timeout: timout)
    }
    
    public func createEvent(event: Event, completionHandler:  @escaping (JSON?, Error?) -> Void) {
        assert(event.event != Event.unsetEvent || event.properties?.isEmpty == false, "Properties cannot be empty for $unset event")
        
        networkConnection.request(URLForCreatingEvent, method: .post, parameters: event.toJSON(), completionHandler: completionHandler)
    }
    
//    public func createBatchEvents(events: [Event], completionHandler:  @escaping (JSON?, Error?) -> Void) {
//        let eventsJSON = events.map { event in event.toJSON() }
//        networkConnection.request(URLForCreatingBatchEvents, method: .post, parameters: eventsJSON, completionHandler: completionHandler)
//    }
    
    public func getEvent(eventID: String, completionHandler: @escaping (JSON?, Error?) -> Void) {
        if let escapedEventID = eventID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            networkConnection.request(URLForGettingEvent(eventID: escapedEventID), method: .get, completionHandler: completionHandler)
        }
    }
    
    public func deleteEvent(eventID: String, completionHandler: @escaping (JSON?, Error?) -> Void) {
        if let escapedEventID = eventID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            networkConnection.request(URLForGettingEvent(eventID: escapedEventID), method: .delete, completionHandler: completionHandler)
        }
    }
    
    lazy var URLForCreatingEvent: String = {
        return "\(baseURL)/events.json?accessKey=\(accessKey)"
    }()
    
    lazy var URLForCreatingBatchEvents: String = {
        return "\(baseURL)/batch/events.json?accessKey=\(accessKey)"
    }()
    
    func URLForGettingEvent(eventID: String) -> String {
        return "\(baseURL)/events/\(eventID).json?accessKey=\(accessKey)"
    }
}

public extension EventClient {
    public func setUser(userID: String, properties: JSON, eventTime: Date = Date(), completionHandler: @escaping (JSON?, Error?) -> Void) {
        
        let userEvent = Event(
            event: Event.setEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: userEvent, completionHandler: completionHandler)
    }
    
    public func unsetUser(userID: String, properties: JSON, eventTime: Date = Date(), completionHandler: @escaping (JSON?, Error?) -> Void) {
        let userEvent = Event(
            event: Event.unsetEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: userEvent, completionHandler: completionHandler)
    }
    
    public func deleteUser(userID: String, eventTime: Date = Date(), completionHandler: @escaping (JSON?, Error?) -> Void) {
        let userEvent = Event(
            event: Event.deleteEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            eventTime: eventTime
        )
        
        createEvent(event: userEvent, completionHandler: completionHandler)
    }
}

public extension EventClient {
    public func setItem(itemID: String, properties: JSON, eventTime: Date = Date(), completionHandler: @escaping (JSON?, Error?) -> Void) {
        let itemEvent = Event(
            event: Event.setEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: itemEvent, completionHandler: completionHandler)
    }
    
    public func unsetItem(itemID: String, properties: JSON, eventTime: Date = Date(), completionHandler: @escaping (JSON?, Error?) -> Void) {
        let itemEvent = Event(
            event: Event.unsetEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: itemEvent, completionHandler: completionHandler)
    }
    
    public func deleteItem(itemID: String, eventTime: Date = Date(), completionHandler: @escaping (JSON?, Error?) -> Void) {
        let itemEvent = Event(
            event: Event.deleteEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            eventTime: eventTime
        )
        
        createEvent(event: itemEvent, completionHandler: completionHandler)
    }
}

public extension EventClient {
    public func recordAction(action: String, byUserID userID: String, onItemID itemID: String, properties: JSON = [:], eventTime: Date = Date(), completionHandler: @escaping (JSON?, Error?) -> Void) {
        let event = Event(
            event: action,
            entityType: Event.userEntityType,
            entityID: userID,
            targetEntityType: Event.itemEntityType,
            targetEntityID: itemID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: event, completionHandler: completionHandler)
    }
}


public class EngineClient: BaseClient {
    
    public override init(baseURL: String = "http://localhost:8000", timeout: TimeInterval = 5) {
        super.init(baseURL: baseURL, timeout: timeout)
    }
    
    public func sendQuery(query: JSON, completionHandler:  @escaping (JSON?, Error?) -> Void) {
        networkConnection.request(URLForQuerying, method: .post, parameters: query, completionHandler: completionHandler)
    }
    
    lazy var URLForQuerying: String = {
        return "\(baseURL)/queries.json"
    }()
}

