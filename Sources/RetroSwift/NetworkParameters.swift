//
//  NetworkParameters.swift
//  
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

struct NetworkParameters<D> {
    let decodeType: D.Type
    let urlSession: URLSession
    let method: HTTPMethod
    let url: String
    let headers: [String: String]
    let successStatusCodes: Set<Int>

    var caller: ServiceCaller<D> { ServiceCaller(self) }
}
