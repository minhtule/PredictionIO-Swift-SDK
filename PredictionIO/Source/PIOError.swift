//
//  Error.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/2/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation


enum PIOError: Error {
    case invalidURL(string: String, queryParams: QueryParams?)
    
    enum Request: Error {
        case unauthorized  // Server return 401
        case notFound  // Server returns 404
        case unknownResponse
        case failed(error: Error)
    }
}
