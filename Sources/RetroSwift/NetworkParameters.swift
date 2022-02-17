//
//  NetworkParameters.swift
//  
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

struct NetworkParameters<D> {
    let decodeType: D.Type
    let method: HTTPMethod
    let url: String
    var headers: [String: String]
    let successStatusCodes: Set<Int>

    func caller(requestInterceptor: NetworkRequestInterceptor) -> ServiceCaller<D> {
        ServiceCaller(self, requestInterceptor: requestInterceptor)
    }
}
