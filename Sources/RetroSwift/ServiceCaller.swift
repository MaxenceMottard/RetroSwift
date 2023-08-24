//
//  ServiceCaller.swift
//
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

public class ServiceCaller<Body, Response>: ServiceCalling {
    public var method: HTTPMethod
    public var url: String
    public var headers: [String : String]
    public var successStatusCodes: Set<Int>
    public var requestInterceptor: NetworkRequestInterceptor

    init(
        method: HTTPMethod,
        url: String,
        headers: [String : String],
        successStatusCodes: Set<Int>,
        requestInterceptor: NetworkRequestInterceptor
    ) {
        self.method = method
        self.url = url
        self.headers = headers
        self.successStatusCodes = successStatusCodes
        self.requestInterceptor = requestInterceptor
    }

    public func run(_ request: URLRequest) async throws -> NetworkResult<Data> {
        let (data, response) = try await runRequest(for: request)

        guard let response = response as? HTTPURLResponse else { throw NetworkError.unknownError }

        guard successStatusCodes.contains(response.statusCode) else {
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
}

// private extension ServiceCaller {
//    func generateFileUploadBody(
//        filename: String,
//        filetype: String,
//        data: Data
//    ) throws -> (body: Data, contentType: String) {
//        let boundary = UUID().uuidString
//        let contentType = "multipart/form-data; boundary=\(boundary)"
//
//        guard let boundaryStart = "--\(boundary)\r\n".data(using: .utf8),
//              let boundaryEnd = "--\(boundary)--\r\n".data(using: .utf8),
//              let contentDispositionString = "Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8),
//              let contentTypeString = "Content-Type: \(filetype)\r\n\r\n".data(using: .utf8),
//              let separator = "\r\n".data(using: .utf8) else {
//            throw NetworkError.cantGenerateImageBody
//        }
//
//        var body = Data()
//        body.append(boundaryStart)
//        body.append(contentDispositionString)
//        body.append(contentTypeString)
//        body.append(data)
//        body.append(separator)
//        body.append(boundaryEnd)
//
//        return (body: body, contentType: contentType)
//    }
// }
