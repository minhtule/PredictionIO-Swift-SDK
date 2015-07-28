//
//  PredictionIOSDK.swift
//  PredictionIOSDK
//
//  Created by Minh Tu Le on 2/23/15.
//  Copyright (c) 2015 PredictionIO. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Base Client

/**
    Base client that manages network connections with the server.
*/
public class BaseClient {
    let baseURL: String

    private let networkManager: Manager
    
    // MARK: Constructors
    
    /**
        :param: baseURL The base URL
        :param: timeout The request timeout
    */
    public init(baseURL: String, timeout: NSTimeInterval) {
        self.baseURL = baseURL
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = timeout
        configuration.URLCache = nil
        networkManager = Manager(configuration: configuration)
    }
}

// MARK: - Event

/**
    An `Event` class that represents a PredictionIO's event JSON dictionary in
    its REST API.
*/
public struct Event {
    // MARK: Constants
    
    /// Reversed set event name.
    public static let SetEvent = "$set"
    
    /// Reversed unset event name.
    public static let UnsetEvent = "$unset"
    
    /// Reversed delete event name.
    public static let DeleteEvent = "$delete"
    
    /// Predefined user entity type.
    public static let UserEntityType = "user"
    
    /// Predefined item entity type.
    public static let ItemEntityType = "item"
    
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
    public var properties: [String: AnyObject]?
    
    /// The time of the event.
    public var eventTime: NSDate
    
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
    public init(event: String, entityType: String, entityID: String, targetEntityType: String? = nil, targetEntityID: String? = nil, properties: [String: AnyObject]? = nil, eventTime: NSDate = NSDate()) {
        self.event = event
        self.entityType = entityType
        self.entityID = entityID
        self.targetEntityType = targetEntityType
        self.targetEntityID = targetEntityID
        self.properties = properties
        self.eventTime = eventTime
    }
    
    // MARK: Helpers
    
    func toDictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [
            "event": event,
            "entityType": entityType,
            "entityId": entityID,
            "eventTime": Event.dateTimeFormatter.stringFromDate(eventTime)
        ]
        
        // Target entity type and ID must be specified together.
        if targetEntityType != nil && targetEntityID != nil {
            dict["targetEntityType"] = targetEntityType!
            dict["targetEntityId"] = targetEntityID!
        }
        
        if properties != nil {
            dict["properties"] = properties!
        }
        
        return dict
    }
    
    private static let dateTimeFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()
}

// MARK: - Event Client

/**
    Client for sending data to PredictionIO Event Server.
*/
public class EventClient : BaseClient {
    /// The access key for your application
    let accessKey: String
    
    private var URLForCreatingEvent: String {
        return "\(baseURL)/events.json?accessKey=\(accessKey)"
    }
    
    private var URLForCreatingBatchEvents: String {
        return "\(baseURL)/batch/events.json?accessKey=\(accessKey)"
    }
    
    private func URLForGettingEvent(eventID: String) -> String {
        return "\(baseURL)/events/\(eventID).json?accessKey=\(accessKey)"
    }
    
    // MARK: Constructors
    
    /**
        :param: accessKey The access key for your application
        :param: baseURL The base URL. Default to be http://localhost:7070.
        :param: timeout The request timeout. Default to be 5s.
    */
    public init(accessKey: String, baseURL: String = "http://localhost:7070", timeout: NSTimeInterval = 5) {
        self.accessKey = accessKey
        super.init(baseURL: baseURL, timeout: timeout)
    }
    
    // MARK: Methods
    
    /**
        Create an event in Event Server.
    
        :param: event An `Event` instance that captures the event.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func createEvent(event: Event, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        assert((event.event == Event.UnsetEvent && event.properties?.isEmpty == true) == false, "Properties cannot be empty for $unset event")
        
        networkManager.request(.POST, URLForCreatingEvent, parameters: event.toDictionary(), encoding: .JSON)
            .responseJSON { (request, response, JSON, error) -> Void in
                completionHandler(request, response, JSON, error)
            }
    }
    
    /**
        Create events with a batch request.
    
    
    */
    public func createBatchEvents(events: [Event], completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let eventDicts = events.map { event in event.toDictionary() }
        var error: NSError?
        let request = NSMutableURLRequest(URL: NSURL(string: URLForCreatingBatchEvents)!)
        request.HTTPMethod = Method.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(eventDicts, options: NSJSONWritingOptions.allZeros, error: &error)

        networkManager.request(request)
            .responseJSON { (request, response, JSON, error) -> Void in
                completionHandler(request, response, JSON, error)
            }
    }
    
    // MARK: For development and debugging purpose only.
    
    /**
        Get an event from Event Server.
    
        :param: eventID The event ID
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func getEvent(eventID: String, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        if let escapedEventID = eventID.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            networkManager.request(.GET, URLForGettingEvent(escapedEventID))
                .responseJSON { (request, response, JSON, error) -> Void in
                    completionHandler(request, response, JSON, error)
                }
        }
    }
    
    /**
        Delete an event from Event Server.
    
        :param: eventID The event ID
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func deleteEvent(eventID: String, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        if let escapedEventID = eventID.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            networkManager.request(.DELETE, URLForGettingEvent(escapedEventID))
                .responseJSON { (request, response, JSON, error) -> Void in
                    completionHandler(request, response, JSON, error)
            }
        }
    }
}

// MARK: - Convenience Methods

/*
    For User entities
*/
extension EventClient {
    
    /**
        Sets properties of a user.
    
        :param: userID The user ID.
        :param: properties The properties to be set.
        :param: eventTime The event time.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func setUser(userID: String, properties: [String: AnyObject], eventTime: NSDate = NSDate(), completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let userEvent = Event(
            event: Event.SetEvent,
            entityType: Event.UserEntityType,
            entityID: userID,
            eventTime: eventTime,
            properties: properties
        )
        
        createEvent(userEvent) { (request, response, JSON, error) -> Void in
            completionHandler(request, response, JSON, error)
        }
    }
    
    /**
        Unsets properties of a user.
        
        :param: userID The user ID.
        :param: properties The properties to be unset.
        :param: eventTime The event time.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func unsetUser(userID: String, properties: [String: AnyObject], eventTime: NSDate = NSDate(), completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let userEvent = Event(
            event: Event.UnsetEvent,
            entityType: Event.UserEntityType,
            entityID: userID,
            eventTime: eventTime,
            properties: properties
        )
        
        createEvent(userEvent) { (request, response, JSON, error) -> Void in
            completionHandler(request, response, JSON, error)
        }
    }
    
    /**
        Deletes a user.
        
        :param: userID The user ID.
        :param: eventTime The event time.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func deleteUser(userID: String, eventTime: NSDate = NSDate(), completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let userEvent = Event(
            event: Event.DeleteEvent,
            entityType: Event.UserEntityType,
            entityID: userID,
            eventTime: eventTime
        )
        
        createEvent(userEvent) { (request, response, JSON, error) -> Void in
            completionHandler(request, response, JSON, error)
        }
    }
}

/**
    For Item entities
*/
extension EventClient {

    /**
        Sets properties of an item.
        
        :param: itemID The item ID.
        :param: properties The properties to be set.
        :param: eventTime The event time.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func setItem(itemID: String, properties: [String: AnyObject], eventTime: NSDate = NSDate(), completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let itemEvent = Event(
            event: Event.SetEvent,
            entityType: Event.ItemEntityType,
            entityID: itemID,
            eventTime: eventTime,
            properties: properties
        )
        
        createEvent(itemEvent) { (request, response, JSON, error) -> Void in
            completionHandler(request, response, JSON, error)
        }
    }
    
    /**
        Unsets properties of an item.
        
        :param: itemID The item ID.
        :param: properties The properties to be unset.
        :param: eventTime The event time.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func unsetItem(itemID: String, properties: [String: AnyObject], eventTime: NSDate = NSDate(), completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let itemEvent = Event(
            event: Event.UnsetEvent,
            entityType: Event.ItemEntityType,
            entityID: itemID,
            eventTime: eventTime,
            properties: properties
        )
        
        createEvent(itemEvent) { (request, response, JSON, error) -> Void in
            completionHandler(request, response, JSON, error)
        }
    }
    
    /**
        Deletes an item.
        
        :param: itemID The item ID.
        :param: eventTime The event time.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func deleteItem(itemID: String, eventTime: NSDate = NSDate(), completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let itemEvent = Event(
            event: Event.DeleteEvent,
            entityType: Event.ItemEntityType,
            entityID: itemID,
            eventTime: eventTime
        )
        
        createEvent(itemEvent) { (request, response, JSON, error) -> Void in
            completionHandler(request, response, JSON, error)
        }
    }
}

/**
    For User action on Item
*/
extension EventClient {
    
    /**
        Creates a user-to-item action.
        
        :param: action The event name.
        :param: userID The userID
        :param: itemID The item ID.
        :param: properties The properties of the event.
        :param: eventTime The event time.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func recordAction(action: String, byUserID userID: String, itemID: String, properties: [String: AnyObject] = [:], eventTime: NSDate = NSDate(), completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        let event = Event(
            event: action,
            entityType: Event.UserEntityType,
            entityID: userID,
            eventTime: eventTime,
            targetEntityType: Event.ItemEntityType,
            targetEntityID: itemID,
            properties: properties
        )
        
        createEvent(event) { (request, response, JSON, error) -> Void in
            completionHandler(request, response, JSON, error)
        }
    }
}

// MARK: - Engine Client

/**
    Client for retrieving prediction results from an PredictionIO Engine instance.
*/
public class EngineClient : BaseClient {
    
    private var URLForQuerying: String {
        return "\(baseURL)/queries.json"
    }
    
    // MARK: Constructors
    
    /**
        :param: baseURL Base URL. Default to be http://localhost:8000.
        :param: timeout Request timeout. Default to be 5s.
    */
    public override init(baseURL: String = "http://localhost:8000", timeout: NSTimeInterval = 5) {
        super.init(baseURL: baseURL, timeout: timeout)
    }
    
    // MARK: Methods
    
    /**
        Sends a query to the prediction engine.
    
        :param: query The query dictionary.
        :param: completionHandler The callback to be executed when the request has finished.
    */
    public func sendQuery(query: [String: AnyObject], completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        networkManager.request(.POST, URLForQuerying, parameters: query, encoding: .JSON)
            .responseJSON { (request, response, JSON, error) -> Void in
                completionHandler(request, response, JSON, error)
            }
    }
}
