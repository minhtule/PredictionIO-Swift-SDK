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
    public init(event: String, entityType: String, entityID: String, targetEntityType: String? = nil, targetEntityID: String? = nil, properties: [String: Any]? = nil, eventTime: Date = Date()) {
        if let properties = properties {
            assert(JSONSerialization.isValidJSONObject(properties), "Event's properties is not a valid JSON. \(properties)")
        }
        
        self.event = event
        self.entityType = entityType
        self.entityID = entityID
        self.targetEntityType = targetEntityType
        self.targetEntityID = targetEntityID
        self.properties = properties
        self.eventTime = eventTime
    }
    
    // MARK: Helpers
    
    func toJSON() -> Data? {
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
        
        return try? JSONSerialization.data(withJSONObject: json, options: [])
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


public struct EventResponse: Decodable {
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "eventId"
    }
}


public class EventClient: BaseClient {
    let accessKey: String
    let channel: String?
    
    public init(accessKey: String, baseURL: String = "http://localhost:7070", channel: String? = nil, timout: TimeInterval = 5) {
        self.accessKey = accessKey
        self.channel = channel
        super.init(baseURL: baseURL, timeout: timout)
    }
    
    public func createEvent(event: Event, completionHandler:  @escaping (EventResponse?, Error?) -> Void) {
        assert(event.event != Event.unsetEvent || event.properties?.isEmpty == false, "Properties cannot be empty for $unset event")
        
        networkConnection.post(url: URLForCreatingEvent, payload: event.toJSON(), queryParams: queryParams) { data, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let event = try decoder.decode(EventResponse.self, from: data)
                completionHandler(event, error)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
//    public func createBatchEvents(events: [Event], completionHandler:  @escaping ([String: Any]?, Error?) -> Void) {
//        let eventsJSON = events.map { event in event.toJSON() }
//        networkConnection.request(URLForCreatingBatchEvents, method: .post, parameters: eventsJSON, completionHandler: completionHandler)
//    }
    
//    public func getEvent(eventID: String, completionHandler: @escaping ([String: Any]?, Error?) -> Void) {
//        if let escapedEventID = eventID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
//            networkConnection.request(URLForGettingEvent(eventID: escapedEventID), method: .get, completionHandler: completionHandler)
//        }
//    }
    
//    public func deleteEvent(eventID: String, completionHandler: @escaping ([String: Any]?, Error?) -> Void) {
//        if let escapedEventID = eventID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
//            networkConnection.request(URLForGettingEvent(eventID: escapedEventID), method: .delete, completionHandler: completionHandler)
//        }
//    }
    
    lazy var URLForCreatingEvent: String = {
        return "\(baseURL)/events.json"
    }()
    
    lazy var URLForCreatingBatchEvents: String = {
        return "\(baseURL)/batch/events.json"
    }()
    
    lazy var queryParams: QueryParams = {
        var queryParams = ["accessKey": accessKey]
        
        if let channel = self.channel {
            queryParams["channel"] = channel
        }
        return queryParams
    }()
    
    func URLForGettingEvent(eventID: String) -> String {
        return "\(baseURL)/events/\(eventID).json?accessKey=\(accessKey)"
    }
}

public extension EventClient {
    public func setUser(userID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        
        let userEvent = Event(
            event: Event.setEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: userEvent, completionHandler: completionHandler)
    }
    
    public func unsetUser(userID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let userEvent = Event(
            event: Event.unsetEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: userEvent, completionHandler: completionHandler)
    }
    
    public func deleteUser(userID: String, eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
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
    public func setItem(itemID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let itemEvent = Event(
            event: Event.setEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: itemEvent, completionHandler: completionHandler)
    }
    
    public func unsetItem(itemID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let itemEvent = Event(
            event: Event.unsetEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            properties: properties,
            eventTime: eventTime
        )
        
        createEvent(event: itemEvent, completionHandler: completionHandler)
    }
    
    public func deleteItem(itemID: String, eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
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
    public func recordAction(action: String, byUserID userID: String, onItemID itemID: String, properties: [String: Any] = [:], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
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
    
//    public func sendQuery(query: [String: Any], completionHandler:  @escaping (JSON?, Error?) -> Void) {
//        networkConnection.request(URLForQuerying, method: .post, parameters: query, completionHandler: completionHandler)
//    }
    
    lazy var URLForQuerying: String = {
        return "\(baseURL)/queries.json"
    }()
}

