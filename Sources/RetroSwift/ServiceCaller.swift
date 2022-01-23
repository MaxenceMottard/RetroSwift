//
//  ServiceCaller.swift
//  
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

public class ServiceCaller<D> {
    private let requestInterceptor: NetworkRequestInterceptor
    private let params: NetworkParameters<D>

    init(_ params: NetworkParameters<D>, requestInterceptor: NetworkRequestInterceptor) {
        self.params = params
        self.requestInterceptor = requestInterceptor
    }

    //  MARK: Public functions

    //  MARK: Without body
    public func call(queryParameters: [String: Any] = [:]) async throws -> D where D: Decodable {
        let request = try await generateRequest(queryParameters: queryParameters)
        let data = try await genericCall(request)

        return try requestInterceptor.jsonDecoder.decode(D.self, from: data)
    }

    public func call(queryParameters: [String: Any] = [:]) async throws {
        let request = try await generateRequest(queryParameters: queryParameters)
        _ = try await genericCall(request)
    }

    //  MARK: With body
    public func call<T: Encodable>(body: T, queryParameters: [String: Any] = [:]) async throws -> D where D: Decodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters)
        let data = try await genericCall(request)

        return try requestInterceptor.jsonDecoder.decode(D.self, from: data)
    }

    public func call<T: Encodable>(body: T, queryParameters: [String: Any] = [:]) async throws {
        let request = try await generateRequest(with: body, queryParameters: queryParameters)
        _ = try await genericCall(request)
    }

    //  MARK: Private functions
    private func genericCall(_ request: URLRequest) async throws -> Data {

        let (data, response) = try await requestInterceptor.urlSession.dataAsync(from: request)

        guard let response = response as? HTTPURLResponse else { throw NetworkError.unknownError }

        guard params.successStatusCodes.contains(response.statusCode) else {
            throw NetworkError.statusCodeError(
                response.statusCode,
                try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            )
        }

        return data
    }

    private func generateRequest<T: Encodable>(with body: T, queryParameters: [String: Any]) async throws -> URLRequest {
        guard let encodedBody = try? requestInterceptor.jsonEncoder.encode(body) else { throw NetworkError.encodeError }

        var request = try await generateRequest(queryParameters: queryParameters)
        request.httpBody = encodedBody

        return request
    }

    private func generateRequest(queryParameters: [String: Any]) async throws -> URLRequest {
        guard var url = URL(string: params.url) else { throw NetworkError.wrongUrl }

        if queryParameters.values.count > 0, var component = URLComponents(string: url.absoluteString) {
            component.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }

            url = component.url ?? url
        }

        var request = URLRequest(url: url)
        request.httpMethod = params.method.rawValue

        params.headers.forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }

        try await requestInterceptor.intercept(&request)

        return request
    }
}
