//
//  File.swift
//
//
//  Created by Maxence Mottard on 08/10/2022.
//

import Foundation

public extension Result where Success: Any, Failure: Error {
    var throwable: Success {
        get throws {
            switch self {
            case let .success(success):
                return success
            case let .failure(failure):
                throw failure
            }
        }
    }
}
