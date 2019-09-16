//
//  PredictionIO.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/1/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation

/// Manages network connections with the server.
public class BaseClient {
    let baseURL: String
    let networkConnection: NetworkConnection

    /// Creates a client instance with specific configuration
    ///
    /// - parameter baseURL: The base URL of the server's endpoints.
    /// - parameter timeout: The request timeout
    ///
    /// - returns: The new `BaseClient` instance.
    init(baseURL: String, timeout: TimeInterval) {
        self.baseURL = baseURL

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration)
        networkConnection = NetworkConnection(session: session)
    }
}

// MARK: -

/// Responsible for retrieving prediction results from a PredictionIO Engine Server.
public class EngineClient: BaseClient {

    // MARK: - Initialization

    /// Creates a client instance to connect to the Engine Server.
    ///
    /// - parameter baseURL: The base URL of the Engine Server. `http://localhost:8000` by default.
    /// - parameter timeout: The request timeout. 5 seconds by default.
    ///
    /// - returns: The `EngineClient` instance.
    public override init(baseURL: String = "http://localhost:8000", timeout: TimeInterval = 5) {
        super.init(baseURL: baseURL, timeout: timeout)
    }

    // MARK: - Querying

    /// Queries the prediction engine.
    ///
    /// - parameter query: The query dictionary.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    public func sendQuery(_ query: [String: Any], completionHandler: @escaping (Result<Data, PIOError>) -> Void) {
        networkConnection.post(url: queriesURL, payload: query, completionHandler: completionHandler)
    }

    /// Queries the prediction engine and parses the response into the given response type.
    ///
    /// - parameter query: The query dictionary.
    /// - parameter responseType: The type respresenting the response format. It must conform to `Decodable`.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    public func sendQuery<Response>(_ query: [String: Any], responseType: Response.Type, completionHandler: @escaping (Result<Response, PIOError>) -> Void) where Response: Decodable {
        networkConnection.post(url: queriesURL, payload: query) { result in
            let result = result.flatMap { data -> Result<Response, PIOError> in
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Response.self, from: data)
                    return .success(response)
                } catch {
                    return .failure(PIOError.DeserializationFailureReason.unknownFormatError())
                }
            }
            completionHandler(result)
        }
    }

    var queriesURL: String { return "\(baseURL)/queries.json" }
}

// MARK: -

/// Responsible for sending data to a PredictionIO Event Server.
public class EventClient: BaseClient {
    let accessKey: String
    let channel: String?

    // MARK: - Initialization

    /// Creates a client instance to connect to the Event Server.
    ///
    /// - parameter accessKey: The access key to the Event Server's app.
    /// - parameter baseURL: The base URL of the Event Server. `http://localhost:8000` by default.
    /// - parameter channel: The channel name of the app. `nil` by default.
    /// - parameter timeout: The request timeout. 5 seconds by default.
    ///
    /// - returns: The `EventClient` instance.
    public init(accessKey: String, baseURL: String = "http://localhost:7070", channel: String? = nil, timout: TimeInterval = 5) {
        self.accessKey = accessKey
        self.channel = channel
        super.init(baseURL: baseURL, timeout: timout)
    }

    // MARK: Managing events

    /// Creates an event in the Event Server.
    ///
    /// - parameter event: The `Event` to be created.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    public func createEvent(_ event: Event, completionHandler: @escaping (Result<CreateEventResponse, PIOError>) -> Void) {
        networkConnection.post(url: eventsURL, payload: event.json, queryParams: queryParams) { result in
            let result = result.flatMap { data -> Result<CreateEventResponse, PIOError> in
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(CreateEventResponse.self, from: data)
                    return .success(response)
                } catch {
                    return .failure(PIOError.DeserializationFailureReason.failedError(error))
                }
            }
            completionHandler(result)
        }
    }

    /// Creates a batch of events in the Event Server.
    ///
    /// - parameter events: The `Event`s to be created.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    public func createBatchEvents(_ events: [Event], completionHandler: @escaping (Result<CreateBatchEventsResponse, PIOError>) -> Void) {
        let eventsJSON = events.map { $0.json }
        networkConnection.post(url: batchEventsURL, payload: eventsJSON, queryParams: queryParams) { result in
            let result = result.flatMap { data -> Result<CreateBatchEventsResponse, PIOError> in
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(CreateBatchEventsResponse.self, from: data)
                    return .success(response)
                } catch {
                    return .failure(PIOError.DeserializationFailureReason.failedError(error))
                }
            }
            completionHandler(result)
        }
    }

    /// Retrieves an event from the Event Server.
    ///
    /// - parameter eventID: The event ID.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    public func getEvent(eventID: String, completionHandler: @escaping (Result<Event, PIOError>) -> Void) {
        do {
            let url = try eventURL(for: eventID)
            networkConnection.get(url: url, queryParams: queryParams) { result in
                let result = result.flatMap { data -> Result<Event, PIOError> in
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            let event = try Event(json: json)
                            return .success(event)
                        } else {
                            return .failure(PIOError.DeserializationFailureReason.unknownFormatError())
                        }
                    } catch {
                        return .failure(PIOError.DeserializationFailureReason.failedError(error))
                    }
                }
                completionHandler(result)
            }
        } catch {
            completionHandler(.failure(error as! PIOError))
        }
    }

    /// Retrieves events from the Event Server.
    ///
    /// - parameter startTime: Find events with `eventTime >= startTime`. `nil` by default.
    /// - parameter endTime: Find events with `eventTime < endTime`. `nil` by default.
    /// - parameter entityType: Find events with this `entityType` only. `nil` by default.
    /// - parameter entityID: Find events with this `entityID` only. `nil` by default.
    /// - parameter limit: The number of record events returned. Set -1 to get all. 20 by default.
    /// - parameter reversed: Returns events in reversed chronological order. Must be used with
    ///     both `entityType` and `entityID` specified. `false` by default.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    public func getEvents(startTime: Date? = nil, endTime: Date? = nil, entityType: String? = nil, entityID: String? = nil, limit: Int = 20, isReversed: Bool = false, completionHandler: @escaping (Result<[Event], PIOError>) -> Void) {
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

        networkConnection.get(url: eventsURL, queryParams: queryParams) { result in
            let result = result.flatMap { data -> Result<[Event], PIOError> in
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        let events = try jsonArray.map { try Event(json: $0) }
                        return .success(events)
                    } else {
                        return .failure(PIOError.DeserializationFailureReason.unknownFormatError())
                    }
                } catch {
                    return .failure(PIOError.DeserializationFailureReason.failedError(error))
                }
            }
            completionHandler(result)
        }
    }

    /// Deletes an event from the Event Server.
    ///
    /// - parameter eventID: The event ID.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    public func deleteEvent(eventID: String, completionHandler: @escaping (PIOError?) -> Void) {
        do {
            let url = try eventURL(for: eventID)
            networkConnection.delete(url: url, queryParams: queryParams) { result in
                switch result {
                case .success:
                    // Event server would return a message in payload but not useful.
                    completionHandler(nil)
                case .failure(let error):
                    completionHandler(error)
                }
            }
        } catch {
            completionHandler(error as? PIOError)
        }
    }

    var eventsURL: String { return "\(baseURL)/events.json" }
    var batchEventsURL: String { return "\(baseURL)/batch/events.json" }
    var queryParams: QueryParams {
        var queryParams = ["accessKey": accessKey]
        queryParams["channel"] = channel
        return queryParams
    }

    func eventURL(for eventID: String) throws -> String {
        if let escapedEventID = eventID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            return "\(baseURL)/events/\(escapedEventID).json"
        } else {
            throw PIOError.invalidEvent(reason: .invalidEventID)
        }
    }
}

// MARK: - Convenience methods

public extension EventClient {
    // MARK: - Managing User entity type

    /// Sets properties of a user.
    ///
    /// - parameter userID: The user ID.
    /// - parameter properties: The properties to be set.
    /// - parameter eventTime: The event time. Current local time by default.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    func setUser(userID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (Result<CreateEventResponse, PIOError>) -> Void) {

        let userEvent = Event(
            event: Event.setEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            properties: properties,
            eventTime: eventTime
        )

        createEvent(userEvent, completionHandler: completionHandler)
    }

    /// Unsets properties of a user.
    ///
    /// - parameter userID: The user ID.
    /// - parameter properties: The properties to be unset.
    /// - parameter eventTime: The event time. Current local time by default.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    func unsetUser(userID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (Result<CreateEventResponse, PIOError>) -> Void) {
        let userEvent = Event(
            event: Event.unsetEvent,
            entityType: Event.userEntityType,
            entityID: userID,
            properties: properties,
            eventTime: eventTime
        )

        createEvent(userEvent, completionHandler: completionHandler)
    }

    /// Deletes a user.
    ///
    /// - parameter userID: The user ID.
    /// - parameter eventTime: The event time. Current local time by default.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    func deleteUser(userID: String, eventTime: Date = Date(), completionHandler: @escaping (Result<CreateEventResponse, PIOError>) -> Void) {
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
    // MARK: - Managing Item entity type

    /// Sets properties of an item.
    ///
    /// - parameter itemID: The item ID.
    /// - parameter properties: The properties to be set.
    /// - parameter eventTime: The event time. Current local time by default.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    func setItem(itemID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (Result<CreateEventResponse, PIOError>) -> Void) {
        let itemEvent = Event(
            event: Event.setEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            properties: properties,
            eventTime: eventTime
        )

        createEvent(itemEvent, completionHandler: completionHandler)
    }

    /// Unsets properties of an item.
    ///
    /// - parameter itemID: The item ID.
    /// - parameter properties: The properties to be unset.
    /// - parameter eventTime: The event time. Current local time by default.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    func unsetItem(itemID: String, properties: [String: Any], eventTime: Date = Date(), completionHandler: @escaping (Result<CreateEventResponse, PIOError>) -> Void) {
        let itemEvent = Event(
            event: Event.unsetEvent,
            entityType: Event.itemEntityType,
            entityID: itemID,
            properties: properties,
            eventTime: eventTime
        )

        createEvent(itemEvent, completionHandler: completionHandler)
    }

    /// Deletes an item.
    ///
    /// - parameter itemID: The item ID.
    /// - parameter eventTime: The event time. Current local time by default.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    func deleteItem(itemID: String, eventTime: Date = Date(), completionHandler: @escaping (Result<CreateEventResponse, PIOError>) -> Void) {
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
    // MARK: - Recording User-Item action

    /// Creates a user-to-item action.
    ///
    /// - parameter action: The action to be used as event name.
    /// - parameter userID: The userID.
    /// - parameter itemID: The item ID.
    /// - parameter properties: The properties of the event. `nil` by default.
    /// - parameter eventTime: The event time. Current local time by default.
    /// - parameter completionHandler: The callback to be executed when the request has finished.
    func recordAction(_ action: String, byUserID userID: String, onItemID itemID: String, properties: [String: Any]? = nil, eventTime: Date = Date(), completionHandler: @escaping (Result<CreateEventResponse, PIOError>) -> Void) {
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

// MARK: - Responses

/// Represents the response of a creating event request.
public struct CreateEventResponse: Decodable {
    /// The event ID of the created event.
    public let eventID: String

    enum CodingKeys: String, CodingKey {
        case eventID = "eventId"
    }
}

/// Represents the response of a creating batch events request.
public struct CreateBatchEventsResponse: Decodable {
    /// The statuses each of which presents whether an event was successfully
    /// created by the server.
    ///
    /// If an event was successfuly created by the server, its status is a
    /// `Result.success` which value contains its individual `CreateEventResponse`.
    /// Otherwise, the event's status is a `Result.failure`. The statuses are
    /// returned in the same order of their corresponding events sent in the
    /// request.
    public let statuses: [Result<CreateEventResponse, PIOError>]

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        var statuses: [Result<CreateEventResponse, PIOError>] = []
        var container = try decoder.unkeyedContainer()

        while !container.isAtEnd {
            let status = try container.decode(Status.self)
            statuses.append(status.asResult)
        }

        self.statuses = statuses
    }

    // Helper enum to facilitate decoding proccess.
    private enum Status: Decodable {
        case success(CreateEventResponse)
        case failure(Int, String)

        enum CodingKeys: String, CodingKey {
            case status
            case message
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let statusCode = try container.decode(Int.self, forKey: .status)

            switch statusCode {
            case 201:
                let createEventResponse = try CreateEventResponse(from: decoder)
                self = .success(createEventResponse)
            default:
                let message = try container.decode(String.self, forKey: .message)
                self = .failure(statusCode, message)
            }
        }

        var asResult: Result<CreateEventResponse, PIOError> {
            switch self {
            case let .success(response):
                return .success(response)
            case let .failure(statusCode, message):
                return .failure(PIOError.RequestFailureReason.serverFailureError(statusCode: statusCode, message: message))
            }
        }
    }
}
