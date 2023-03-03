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
    ) async throws -> Data where Response == Data, Body == Void {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)

        return try await genericCall(request)
    }

    public func callAsFunction(
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> Response where Response: Decodable, Body == Void {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let data = try await genericCall(request)

        return try requestInterceptor.jsonDecoder.decode(Response.self, from: data)
    }

    public func callAsFunction(
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws where Body == Void, Response == Void {
        let request = try await generateRequest(queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        _ = try await genericCall(request)
    }

    public func uploadFile(filename: String, filetype: String, data: Data) async throws where Response == Void {
        let fileUploadingData = try generateFileUploadBody(filename: filename, filetype: filetype, data: data)
        params.headers["Content-Type"] = fileUploadingData.contentType
        var request = try await generateRequest(queryParameters: [:], pathKeysValues: [:])
        request.httpBody = fileUploadingData.body
        _ = try await genericCall(request)
    }

    public func uploadFile(filename: String, filetype: String, data: Data) async throws -> Response where Response: Decodable {
        let fileUploadingData = try generateFileUploadBody(filename: filename, filetype: filetype, data: data)
        params.headers["Content-Type"] = fileUploadingData.contentType
        var request = try await generateRequest(queryParameters: [:], pathKeysValues: [:])
        request.httpBody = fileUploadingData.body
        let data = try await genericCall(request)

        return try requestInterceptor.jsonDecoder.decode(Response.self, from: data)
    }

    // MARK: With body

    public func callAsFunction(
        body: Body,
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> Data where Response == Data, Body: Encodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters, pathKeysValues: pathKeysValues)

        return try await genericCall(request)
    }

    public func callAsFunction(
        body: Body,
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws -> Response where Response: Decodable, Body: Encodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        let data = try await genericCall(request)

        return try requestInterceptor.jsonDecoder.decode(Response.self, from: data)
    }

    public func callAsFunction(
        body: Body,
        queryParameters: [String: Any] = [:],
        pathKeysValues: [String: String] = [:]
    ) async throws where Response == Void, Body: Encodable {
        let request = try await generateRequest(with: body, queryParameters: queryParameters, pathKeysValues: pathKeysValues)
        _ = try await genericCall(request)
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

    private func genericCall(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await runRequest(for: request)

        guard let response = response as? HTTPURLResponse else { throw NetworkError.unknownError }

        guard params.successStatusCodes.contains(response.statusCode) else {
            throw NetworkError.statusCodeError(
                response.statusCode,
                try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            )
        }

        return data
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
