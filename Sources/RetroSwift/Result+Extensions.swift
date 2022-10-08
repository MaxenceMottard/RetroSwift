//
//  File.swift
//  
//
//  Created by Maxence Mottard on 08/10/2022.
//

import Foundation

extension Result where Success: Any, Failure: Error {
    public var throwable: Success {
        get throws {
            switch self {
                case .success(let success):
                    return success
                case .failure(let failure):
                    throw failure
            }
        }
    }
}
