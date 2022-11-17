//
//  HTTPMethod.swift
//
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

/// Enum to specify HTTP verb for request
public enum HTTPMethod: String {
    /// POST request verb
    case POST
    /// GET request verb
    case GET
    /// PUT request verb
    case PUT
    /// PATCH request verb
    case PATCH
    /// DELETE request verb
    case DELETE
}
