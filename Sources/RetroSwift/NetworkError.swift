//
//  NetworkError.swift
//
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

/// Network errors which can be throwed by the `ServiceCaller`
public enum NetworkError: Error {
    case cantGenerateRequest
    case cantGenerateImageBody
    case decodeError
    case encodeError
    case wrongURL
    case statusCodeError(Int, [String: Any]?)
    case unknownError
    case custom(String)
}
