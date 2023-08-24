//
//  NetworkResult.swift
//  
//
//  Created by Maxence Mottard on 24/08/2023.
//

import Foundation

public struct NetworkResult<D> {
    public let response: HTTPURLResponse
    private let _data: D

    public init(response: HTTPURLResponse, data: D) {
        self.response = response
        self._data = data
    }
}

public extension NetworkResult where D: Decodable {
    var data: D { _data }
}

public extension NetworkResult where D == Data {
    var data: D { _data }
}

public extension NetworkResult where D == Void {
    init(response: HTTPURLResponse) {
        self.response = response
        self._data = ()
    }
}
