//
//  File.swift
//
//
//  Created by Maxence on 22/01/2022.
//

import Foundation

public protocol NetworkRequestInterceptor {
    var urlSession: URLSession { get }

    var jsonDecoder: JSONDecoder { get }
    var jsonEncoder: JSONEncoder { get }

    func intercept(_ request: inout URLRequest) async throws
}

public extension NetworkRequestInterceptor {
    var urlSession: URLSession {
        .shared
    }

    var jsonDecoder: JSONDecoder {
        JSONDecoder()
    }

    var jsonEncoder: JSONEncoder {
        JSONEncoder()
    }
}

public protocol DataNetworkRequestInterceptor: NetworkRequestInterceptor {
    associatedtype DecodedType

    func runURLRequest(from request: URLRequest) async throws -> (Data, URLResponse)
}

extension DataNetworkRequestInterceptor {
    func runURLRequest(from request: URLRequest) async throws -> (Data, URLResponse) {
        try await urlSession.dataAsync(from: request)
    }
}

final class DefaultNetworkRequestInterceptor: NetworkRequestInterceptor {
    func intercept(_ request: inout URLRequest) async throws {}
}
