//
//  NetworkError.swift
//  
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

public enum NetworkError: Error {
    case cantGenerateRequest
    case decodeError
    case encodeError
    case wrongUrl
    case statusCodeError(Int, [String: Any]?)
    case unknownError
    case custom(String)
}
