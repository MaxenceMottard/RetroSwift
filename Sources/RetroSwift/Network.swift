//
//  Network.swift
//  
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

@propertyWrapper
public struct Network<D> {
    public var wrappedValue: ServiceCaller<D>

    public var requestInterceptor: NetworkRequestInterceptor? {
        set {
            wrappedValue.requestInterceptor = newValue
        }
        get {
            wrappedValue.requestInterceptor
        }
    }

    public init(
        url: String,
        method: HTTPMethod,
        headers: [String: String] = ["Content-Type": "application/json"],
        successStatusCodes: Set<Int> = Set<Int>(200...209),
        urlSession: URLSession = .shared
    ) {
        wrappedValue = NetworkParameters(
            decodeType: D.self,
            urlSession: urlSession,
            method: method,
            url: url,
            headers: headers,
            successStatusCodes: successStatusCodes
        ).caller
    }
}
