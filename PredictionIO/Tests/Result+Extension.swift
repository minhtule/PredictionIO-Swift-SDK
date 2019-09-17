//
//  Result+Extension.swift
//  PredictionIO iOS
//
//  Created by Minh Tu Le on 9/16/19.
//  Copyright © 2019 PredictionIO. All rights reserved.
//

import Foundation

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    var isFailure: Bool {
        return !isSuccess
    }

    var value: Success? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }

    var error: Failure? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
}
