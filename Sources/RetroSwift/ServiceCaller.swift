//
//  ServiceCaller.swift
//  
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

public protocol NetworkRequestInterceptor {
    func intercept(_ request: inout URLRequest) async throws
}

public class ServiceCaller<D> {
    var requestInterceptor: NetworkRequestInterceptor?
    private let params: NetworkParameters<D>

    init(_ params: NetworkParameters<D>) {
        self.params = params
    }

    private var jsonDecoder: JSONDecoder {
        return JSONDecoder()
    }
    private var jsonEncoder: JSONEncoder {
        return JSONEncoder()
    }

    //  MARK: Public functions

    //  MARK: Without body
    public func call() async throws -> D where D: Decodable {
        let request = try await generateRequest()
        let data = try await genericCall(request)

        return try jsonDecoder.decode(D.self, from: data)
    }

    public func call() async throws {
        let request = try await generateRequest()
        _ = try await genericCall(request)
    }

    //  MARK: With body
    public func call<T: Encodable>(body: T) async throws -> D where D: Decodable {
        let request = try await generateRequest(with: body)
        let data = try await genericCall(request)

        return try jsonDecoder.decode(D.self, from: data)
    }

    public func call<T: Encodable>(body: T) async throws {
        let request = try await generateRequest(with: body)
        _ = try await genericCall(request)
    }

    //  MARK: Private functions
    private func genericCall(_ request: URLRequest) async throws -> Data {

        let (data, response) = try await params.urlSession.dataAsync(from: request)

        guard let response = response as? HTTPURLResponse else { throw NetworkError.unknownError }

        guard params.successStatusCodes.contains(response.statusCode) else {
            throw NetworkError.statusCodeError(
                response.statusCode,
                try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            )
        }

        return data
    }

    private func generateRequest<T: Encodable>(with body: T) async throws -> URLRequest {
        guard let encodedBody = try? jsonEncoder.encode(body) else { throw NetworkError.encodeError }

        var request = try await generateRequest()
        request.httpBody = encodedBody

        return request
    }

    private func generateRequest() async throws -> URLRequest {
        guard let url = URL(string: params.url) else { throw NetworkError.wrongUrl }

        var request = URLRequest(url: url)
        request.httpMethod = params.method.rawValue

        params.headers.forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }

        try await requestInterceptor?.intercept(&request)

        return request
    }
}
