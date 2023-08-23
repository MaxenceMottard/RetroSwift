//
//  ServiceCaller.swift
//
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

public class ServiceCaller<Body, Response> {
    private let requestInterceptor: NetworkRequestInterceptor
    private var params: NetworkParameters<Body, Response>

    init(_ params: NetworkParameters<Body, Response>, requestInterceptor: NetworkRequestInterceptor) {
        self.params = params
        self.requestInterceptor = requestInterceptor
    }

    // MARK: Without body

    public func callAsFunction(
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Data> where Response == Data, Body == Void {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)

        return try await genericCall(request)
    }

    public func callAsFunction(
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Response> where Response: Decodable, Body == Void {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let result = try await genericCall(request)
        let decodedData = try requestInterceptor.jsonDecoder.decode(Response.self, from: result.data)

        return .init(response: result.response, data: decodedData)
    }

    @discardableResult
    public func callAsFunction(
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Void> where Body == Void, Response == Void {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let result = try await genericCall(request)

        return .init(response: result.response)
    }

    @discardableResult
    public func uploadFile(
        filename: String,
        filetype: String,
        data: Data
    ) async throws -> NetworkResult<Void> where Response == Void {
        let fileUploadingData = try generateFileUploadBody(filename: filename, filetype: filetype, data: data)
        params.headers["Content-Type"] = fileUploadingData.contentType
        var request = try await generateRequest(queryParameters: [:], pathKeysValues: [:])
        request.httpBody = fileUploadingData.body
        let result = try await genericCall(request)

        return .init(response: result.response)
    }

    public func uploadFile(filename: String, filetype: String, data: Data) async throws -> NetworkResult<Response> where Response: Decodable {
        let fileUploadingData = try generateFileUploadBody(filename: filename, filetype: filetype, data: data)
        params.headers["Content-Type"] = fileUploadingData.contentType
        var request = try await generateRequest(queryParameters: [:], pathKeysValues: [:])
        request.httpBody = fileUploadingData.body
        let result = try await genericCall(request)
        let decodedData = try requestInterceptor.jsonDecoder.decode(Response.self, from: result.data)

        return .init(response: result.response, data: decodedData)
    }

    // MARK: With body

    public func callAsFunction(
        body: Body,
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Data> where Response == Data, Body: Encodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters, pathKeysValues: pathKeysValues)

        return try await genericCall(request)
    }

    public func callAsFunction(
        body: Body,
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> NetworkResult<Response> where Response: Decodable, Body: Encodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let result = try await genericCall(request)
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
        let result = try await genericCall(request)

        return .init(response: result.response)
    }

    // MARK: Private functions

    private func generateFileUploadBody(
        filename: String,
        filetype: String,
        data: Data
    ) throws -> (body: Data, contentType: String) {
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"

        guard let boundaryStart = "--\(boundary)\r\n".data(using: .utf8),
              let boundaryEnd = "--\(boundary)--\r\n".data(using: .utf8),
              let contentDispositionString = "Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8),
              let contentTypeString = "Content-Type: \(filetype)\r\n\r\n".data(using: .utf8),
              let separator = "\r\n".data(using: .utf8) else {
            throw NetworkError.cantGenerateImageBody
        }

        var body = Data()
        body.append(boundaryStart)
        body.append(contentDispositionString)
        body.append(contentTypeString)
        body.append(data)
        body.append(separator)
        body.append(boundaryEnd)

        return (body: body, contentType: contentType)
    }

    private func genericCall(_ request: URLRequest) async throws -> NetworkResult<Data> {
        let (data, response) = try await runRequest(for: request)

        guard let response = response as? HTTPURLResponse else { throw NetworkError.unknownError }

        guard params.successStatusCodes.contains(response.statusCode) else {
            throw NetworkError.statusCodeError(
                response.statusCode,
                try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            )
        }

        return .init(response: response, data: data)
    }

    private func runRequest(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let requestInterceptor = requestInterceptor as? (any DataNetworkRequestInterceptor) {
            return try await requestInterceptor.runURLRequest(from: request)
        } else {
            return try await requestInterceptor.urlSession.dataAsync(from: request)
        }
    }

    private func generateRequest(
        with body: some Encodable,
        queryParameters: [String: Any],
        pathKeysValues: [String: String]
    ) async throws -> URLRequest {
        guard let encodedBody = try? requestInterceptor.jsonEncoder.encode(body) else { throw NetworkError.encodeError }

        var request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        request.httpBody = encodedBody

        return request
    }

    private func generateRequest(queryParameters: [String: Any], pathKeysValues: [String: String]) async throws -> URLRequest {
        var urlString = params.url

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
        request.httpMethod = params.method.rawValue

        params.headers.forEach {
            request.addValue($1, forHTTPHeaderField: $0)
        }

        try await requestInterceptor.intercept(&request)

        return request
    }
}

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
