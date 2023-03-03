//
//  NetworkParameters.swift
//
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

struct NetworkParameters<Body, Response> {
    let decodeType: Response.Type
    let bodyType: Body.Type
    let method: HTTPMethod
    let url: String
    var headers: [String: String]
    let successStatusCodes: Set<Int>

    func caller(requestInterceptor: NetworkRequestInterceptor) -> ServiceCaller<Body, Response> {
        ServiceCaller(self, requestInterceptor: requestInterceptor)
    }
}
