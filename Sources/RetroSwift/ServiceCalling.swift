//
//  ServiceCalling.swift
//
//
//  Created by Maxence Mottard on 24/08/2023.
//

import Foundation

public protocol ServiceCalling<Body, Response> {
    associatedtype Body
    associatedtype Response

    var method: HTTPMethod { get }
    var url: String { get }
    var headers: [String: String] { get }
    var successStatusCodes: Set<Int> { get }

    var requestInterceptor: any NetworkRequestInterceptor { get }

    func run(_ request: URLRequest) async throws -> NetworkResult<Data>
}

extension ServiceCalling {
    func generateRequest(queryParameters: [String: Any], pathKeysValues: [String: String]) async throws -> URLRequest {
        var urlString = url

        pathKeysValues.keys.forEach { key in
            guard let value = pathKeysValues[key] else { return }
            urlString = urlString.replacingOccurrences(of: ":\(key)", with: value)
        }

        guard var url = URL(string: urlString) else { throw NetworkError.wrongURL }

        if !queryParameters.values.isEmpty, var component = URLComponents(string: url.absoluteString) {
            component.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }

            url = component.url ?? url
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        headers.forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }

        try await requestInterceptor.intercept(&request)

        return request
    }
}

extension ServiceCalling where Body == Void {
    public func callAsFunction(
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Data> where Response == Data {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)

        return try await run(request)
    }

    public func callAsFunction(
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Response> where Response: Decodable {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let result = try await run(request)
        let decodedData = try requestInterceptor.jsonDecoder.decode(Response.self, from: result.data)

        return .init(response: result.response, data: decodedData)
    }

    @discardableResult
    public func callAsFunction(
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Void> where Response == Void {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let result = try await run(request)

        return .init(response: result.response)
    }
}

extension ServiceCalling where Body: Encodable {
    public func callAsFunction(
        body: Body,
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Data> where Response == Data, Body: Encodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters, pathKeysValues: pathKeysValues)

        return try await run(request)
    }

    public func callAsFunction(
        body: Body,
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Response> where Response: Decodable, Body: Encodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let result = try await run(request)
        let decodedData = try requestInterceptor.jsonDecoder.decode(Response.self, from: result.data)

        return .init(response: result.response, data: decodedData)
    }

    @discardableResult
    public func callAsFunction(
        body: Body,
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Void> where Response == Void, Body: Encodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let result = try await run(request)

        return .init(response: result.response)
    }

    func generateRequest(
        with body: some Encodable,
        queryParameters: [String: Any],
        pathKeysValues: [String: String]
    ) async throws -> URLRequest {
        guard let encodedBody = try? requestInterceptor.jsonEncoder.encode(body) else { throw NetworkError.encodeError }

        var request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        request.httpBody = encodedBody

        return request
    }
}

//extension ServiceCalling {
//    @discardableResult
//    public func uploadFile(
//        filename: String,
//        filetype: String,
//        data: Data
//    ) async throws -> NetworkResult<Void> where Response == Void {
//        let fileUploadingData = try generateFileUploadBody(filename: filename, filetype: filetype, data: data)
//        params.headers["Content-Type"] = fileUploadingData.contentType
//        var request = try await generateRequest(queryParameters: [:], pathKeysValues: [:])
//        request.httpBody = fileUploadingData.body
//        let result = try await run(request)
//        
//        return .init(response: result.response)
//    }
//    
//    public func uploadFile(filename: String, filetype: String, data: Data) async throws -> NetworkResult<Response> where Response: Decodable {
//        let fileUploadingData = try generateFileUploadBody(filename: filename, filetype: filetype, data: data)
//        params.headers["Content-Type"] = fileUploadingData.contentType
//        var request = try await generateRequest(queryParameters: [:], pathKeysValues: [:])
//        request.httpBody = fileUploadingData.body
//        let result = try await run(request)
//        let decodedData = try requestInterceptor.jsonDecoder.decode(Response.self, from: result.data)
//        
//        return .init(response: result.response, data: decodedData)
//    }
//}
