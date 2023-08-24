//
//  Network.swift
//
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

@propertyWrapper
public struct Network<Body, Response> {
    public var wrappedValue: any ServiceCalling<Body, Response>

    /// Init the property wrapper to generate a service caller
    /// - Parameter url: String url for the request.
    /// - Parameter method: The `HTTPMethode` for the request.
    /// - Parameter headers: Headers to use in the request.
    /// - Parameter successStatusCodes: List of status which don't return an error.
    /// - Parameter urlSession: URLSession to use to send request. Use `URLSession.shared` by default.
    public init(
        url: String,
        method: HTTPMethod,
        headers: [String: String] = ["Content-Type": "application/json"],
        successStatusCodes: Set<Int> = Set<Int>(200 ... 209),
        requestInterceptor: NetworkRequestInterceptor? = nil
    ) {
        self.wrappedValue = ServiceCaller(
            method: method,
            url: url,
            headers: headers,
            successStatusCodes: successStatusCodes,
            requestInterceptor: requestInterceptor ?? DefaultNetworkRequestInterceptor()
        )
    }
}
