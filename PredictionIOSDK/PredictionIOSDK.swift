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
    
    private static let dateTimeFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }()
    
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
}

// MARK: - Event Client

public class EventClient : BaseClient {
    let accessKey: String
    
    private var _createEventFullURL: String {
        return "\(baseURL)/events.json?accessKey=\(accessKey)"
    }
    
    public init(accessKey: String, baseURL: String = "http://localhost:7070", timeout: NSTimeInterval = 5) {
        self.accessKey = accessKey
        super.init(baseURL: baseURL, timeout: timeout)
    }
    
    public func createEvent(event: Event, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        _manager.request(.POST, _createEventFullURL, parameters: event.toDictionary(), encoding: .JSON)
                .responseJSON { (request, response, JSON, error) -> Void in
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
