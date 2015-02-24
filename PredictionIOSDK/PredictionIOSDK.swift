//
//  PredictionIOSDK.swift
//  PredictionIOSDK
//
//  Created by Minh Tu Le on 2/23/15.
//  Copyright (c) 2015 PredictionIO. All rights reserved.
//

import Foundation

// MARK: - Base Client

public class BaseClient {
    let baseURL: String
    
    private let _manager: Manager

    
    public init(baseURL: String, timeout: NSTimeInterval) {
        self.baseURL = baseURL
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = timeout
        _manager = Manager(configuration: configuration)
    }
}

// MARK: - Event

public struct Event {
    public var event: String
    public var entityType: String
    public var entityID: String
    public var targetEntityType: String?
    public var targetEntityID: String?
    public var properties: [String: AnyObject]?
    public var eventTime: NSDate
    
    public static let SetEvent = "$set"
    public static let UnsetEvent = "$unset"
    public static let DeleteEvent = "$delete"
    public static let UserEntityType = "user"
    public static let ItemEntityType = "item"
    
    public init(event: String, entityType: String, entityID: String, eventTime: NSDate = NSDate(), targetEntityType: String? = nil, targetEntityID: String? = nil, properties: [String: AnyObject]? = nil) {
        self.event = event
        self.entityType = entityType
        self.entityID = entityID
        self.targetEntityType = targetEntityType
        self.targetEntityID = targetEntityID
        self.properties = properties
        self.eventTime = eventTime
    }
    
    public func toDictionary() -> [String: AnyObject] {
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

public class EventClient : BaseClient {
    let accessKey: String
    
    private var _createEventFullURL: String {
        return "\(baseURL)/events.json?accessKey=\(accessKey)"
    }
    
    private func _getEventFullURL(eventID: String) -> String {
        return "\(baseURL)/events/\(eventID).json?accessKey=\(accessKey)"
    }
    
    public init(accessKey: String, baseURL: String = "http://localhost:7070", timeout: NSTimeInterval = 5) {
        self.accessKey = accessKey
        super.init(baseURL: baseURL, timeout: timeout)
    }
    
    public func createEvent(event: Event, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        if event.event == Event.UnsetEvent && event.properties?.isEmpty == true {
            // Properties cannot be empty for $unset event
            return
        }
        
        _manager.request(.POST, _createEventFullURL, parameters: event.toDictionary(), encoding: .JSON)
                .responseJSON { (request, response, JSON, error) -> Void in
                    completionHandler(request, response, JSON, error)
                }
    }
    
    // MARK: For development and debugging purpose only.
    
    public func getEvent(eventID: String, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        if let escapedEventID = eventID.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            _manager.request(.GET, _getEventFullURL(escapedEventID))
                    .responseJSON { (request, response, JSON, error) -> Void in
                        completionHandler(request, response, JSON, error)
                    }
        }
    }
    
    public func deleteEvent(eventID: String, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        if let escapedEventID = eventID.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            _manager.request(.DELETE, _getEventFullURL(escapedEventID))
                .responseJSON { (request, response, JSON, error) -> Void in
                    completionHandler(request, response, JSON, error)
            }
        }
    }
}

// MARK: - User

extension EventClient {
    
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

// MARK: - Item

extension EventClient {
    
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

// MARK: - User Action on Item

extension EventClient {
    
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

public class EngineClient : BaseClient {
    
    private var _fullURL: String {
        return "\(baseURL)/queries.json"
    }
    
    public override init(baseURL: String = "http://localhost:8000", timeout: NSTimeInterval = 5) {
        super.init(baseURL: baseURL, timeout: timeout)
    }
    
    public func sendQuery(query: [String: AnyObject], completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        _manager.request(.POST, _fullURL, parameters: query, encoding: .JSON)
                .responseJSON { (request, response, JSON, error) -> Void in
                    completionHandler(request, response, JSON, error)
                }
    }
}
