//
//  Error.swift
//  PredictionIO
//
//  Created by Minh Tu Le on 1/2/18.
//  Copyright © 2018 PredictionIO. All rights reserved.
//

import Foundation

enum PIOError: Error {
    case invalidURL(string: String)
    case invalidJSON(json: JSON)
    case jsonEncodingFailed(json: JSON, error: Error)
    case requestFailed(error: Error)
    case jsonDecodingFailed(error: Error)
    
    static func createRequestFailed(error: Error?) -> PIOError? {
        if let error = error {
            return .requestFailed(error: error)
        }
        return nil
    }
}
