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
    public let eventID: String

    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
    }
}

public enum BatchEventStatus: Decodable {
    case success(eventID: String)
    case failed(message: String)

    enum CodingKeys: String, CodingKey {
        case status
        case eventID = "eventId"
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(Int.self, forKey: .status)

        switch status {
        case 201:
            let eventID = try container.decode(String.self, forKey: .eventID)
            self = .success(eventID: eventID)
        case 400:
            let message = try container.decode(String.self, forKey: .message)
            self = .failed(message: message)
        default:
            throw DecodingError.dataCorruptedError(forKey: .status, in: container, debugDescription: "Status code is not supported: \(status).")
        }
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

    public func createEvent(_ event: Event, completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        networkConnection.post(url: eventsURL, payload: event.json, queryParams: queryParams) { data, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let event = try decoder.decode(EventResponse.self, from: data)
                completionHandler(event, nil)
            } catch {
                completionHandler(nil, PIOError.DeserializationFailureReason.failedError(error))
            }
        }
    }

    public func createBatchEvents(_ events: [Event], completionHandler: @escaping ([BatchEventStatus]?, Error?) -> Void) {
        let eventsJSON = events.map { $0.json }
        networkConnection.post(url: batchEventsURL, payload: eventsJSON, queryParams: queryParams) { data, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let eventStatuses = try decoder.decode([BatchEventStatus].self, from: data)
                completionHandler(eventStatuses, nil)
            } catch {
                completionHandler(nil, PIOError.DeserializationFailureReason.failedError(error))
            }
        }
    }

    public func getEvent(eventID: String, completionHandler: @escaping (Event?, Error?) -> Void) {
        do {
            let url = try eventURL(for: eventID)
            networkConnection.get(url: url, queryParams: queryParams) { data, error in
                guard let data = data else {
                    completionHandler(nil, error)
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let event = try Event(json: json)
                        completionHandler(event, nil)
                    } else {
                        throw PIOError.DeserializationFailureReason.unknownFormatError()
                    }
                } catch {
                    if !(error is PIOError) {
                        completionHandler(nil, error)
                    } else {
                        completionHandler(nil, PIOError.DeserializationFailureReason.failedError(error))
                    }
                }
            }
        } catch {
            completionHandler(nil, error)
        }
    }

    public func getEvents(startTime: Date? = nil, endTime: Date? = nil, entityType: String? = nil, entityID: String? = nil, limit: Int = 20, isReversed: Bool = false, completionHandler: @escaping ([Event]?, Error?) -> Void) {
        var queryParams = self.queryParams

        if let startTime = startTime {
            queryParams["startTime"] = Event.dateTimeFormatter.string(from: startTime)
        }

        if let endTime = endTime {
            queryParams["endTime"] = Event.dateTimeFormatter.string(from: endTime)
        }

        queryParams["entityType"] = entityType
        queryParams["entityId"] = entityID
        queryParams["limit"] = String(limit)
        queryParams["reversed"] = String(isReversed)

        networkConnection.get(url: eventsURL, queryParams: queryParams) { data, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }

            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let events = try jsonArray.map { try Event(json: $0) }
                    completionHandler(events, nil)
                } else {
                    throw PIOError.DeserializationFailureReason.unknownFormatError()
                }
            } catch {
                if !(error is PIOError) {
                    completionHandler(nil, error)
                } else {
                    completionHandler(nil, PIOError.DeserializationFailureReason.failedError(error))
                }
            }
        }
    }

    public func deleteEvent(eventID: String, completionHandler: @escaping (Error?) -> Void) {
        do {
            let url = try eventURL(for: eventID)
            networkConnection.get(url: url, queryParams: queryParams) { data, error in
                guard let _ = data else {
                    completionHandler(error)
                    return
                }

                // Event server would return a message in payload but not useful.
                completionHandler(nil)
            }
        } catch {
            completionHandler(error)
        }
    }

    lazy var eventsURL: String = {
        return "\(baseURL)/events.json"
    }()

    lazy var batchEventsURL: String = {
        return "\(baseURL)/batch/events.json"
    }()

    lazy var queryParams: QueryParams = {
        var queryParams = ["accessKey": accessKey]
        queryParams["channel"] = channel
        return queryParams
    }()

    func eventURL(for eventID: String) throws -> String {
        if let escapedEventID = eventID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            return "\(baseURL)/events/\(escapedEventID).json"
        } else {
            throw PIOError.invalidEvent(reason: .invalidEventID)
        }
    }
}

public extension EventClient {
    func setUser(userID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {

        let userEvent = Event(
            event: Event.setEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            properties: properties,
            eventTime: eventTime
        )

        createEvent(userEvent, completionHandler: completionHandler)
    }

    func unsetUser(userID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let userEvent = Event(
            event: Event.unsetEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            properties: properties,
            eventTime: eventTime
        )

        createEvent(userEvent, completionHandler: completionHandler)
    }

    func deleteUser(userID: String, eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let userEvent = Event(
            event: Event.deleteEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            eventTime: eventTime
        )

        createEvent(userEvent, completionHandler: completionHandler)
    }
}

public extension EventClient {
    func setItem(itemID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let itemEvent = Event(
            event: Event.setEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            properties: properties,
            eventTime: eventTime
        )

        createEvent(itemEvent, completionHandler: completionHandler)
    }

    func unsetItem(itemID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let itemEvent = Event(
            event: Event.unsetEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            properties: properties,
            eventTime: eventTime
        )

        createEvent(itemEvent, completionHandler: completionHandler)
    }

    func deleteItem(itemID: String, eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let itemEvent = Event(
            event: Event.deleteEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            eventTime: eventTime
        )

        createEvent(itemEvent, completionHandler: completionHandler)
    }
}

public extension EventClient {
    func recordAction(_ action: String, byUserID userID: String, onItemID itemID: String, properties: [String: Any] = [:], eventTime: Date = Date(), completionHandler: @escaping (EventResponse?, Error?) -> Void) {
        let event = Event(
            event: action,
            entityType: Event.userEntityType,
            entityID: userID,
            targetEntity: (type: Event.itemEntityType, id: itemID),
            properties: properties,
            eventTime: eventTime
        )

        createEvent(event, completionHandler: completionHandler)
    }
}

public class EngineClient: BaseClient {

    public override init(baseURL: String = "http://localhost:8000", timeout: TimeInterval = 5) {
        super.init(baseURL: baseURL, timeout: timeout)
    }

    public func sendQuery(_ query: [String: Any], completionHandler: @escaping (Data?, Error?) -> Void) {
        networkConnection.post(url: queriesURL, payload: query, completionHandler: completionHandler)
    }

    public func sendQuery<Response>(_ query: [String: Any], responseType: Response.Type, completionHandler: @escaping (Response?, Error?) -> Void) where Response: Decodable {
        networkConnection.post(url: queriesURL, payload: query) { data, error in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, PIOError.DeserializationFailureReason.unknownFormatError())
            }
        }
    }

    lazy var queriesURL: String = {
        return "\(baseURL)/queries.json"
    }()
}
