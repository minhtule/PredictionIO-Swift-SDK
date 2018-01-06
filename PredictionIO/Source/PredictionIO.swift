//
//  PredictionIO.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/1/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation


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
        do {
            let payload = try JSONSerialization.data(withJSONObject: event.json, options: [])
            networkConnection.post(url: URLForCreatingEvent, payload: payload, queryParams: queryParams) { data, error in
                guard let data = data else {
                    completionHandler(nil, error)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let event = try decoder.decode(EventResponse.self, from: data)
                    completionHandler(event, error)
                } catch {
                    completionHandler(nil, PIOError.DeserializationFailureReason.failedError(error))
                }
            }
        } catch {
            completionHandler(nil, PIOError.SerializationFailureReason.failedError(error))
            return
        }
    }
    
//    public func createBatchEvents(events: [Event], completionHandler:  @escaping ([String: Any]?, Error?) -> Void) {
//        let eventsJSON = events.map { event in event.toJSON() }
//        networkConnection.request(URLForCreatingBatchEvents, method: .post, parameters: eventsJSON, completionHandler: completionHandler)
//    }
    
//    public func getEvent(eventID: String, completionHandler: @escaping ([String: Any]?, Error?) -> Void) {
//        if let escapedEventID = eventID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
//            let url = URLForGettingEvent(eventID: escapedEventID)
//            networkConnection.get(url: url, completionHandler: completionHandler)
//        } else {
//            completionHandler(nil, PIOError.invalidEventID(id: eventID))
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

