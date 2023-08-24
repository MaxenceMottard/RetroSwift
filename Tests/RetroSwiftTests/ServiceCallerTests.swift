import XCTest
@testable import RetroSwift

final class ServiceCallerTests: XCTestCase {

    func test_givenServiceCallerWithEncodableBodyAndVoidResponse_whenGenerateRequest_thenAsCorrectUrlRquest() async throws {
        // Given
        var receivedUrlRequest: URLRequest!
        var requestInterceptor = RequestInterceptor<CodableModel>()
        requestInterceptor.runClosure = { receivedUrlRequest = $0 }
        requestInterceptor.runResultData = Data()

        let sut = Network<CodableModel, Void>(
            url: "https://github.com/:username",
            method: .GET,
            headers: [:],
            requestInterceptor: requestInterceptor
        ).wrappedValue

        // When
        _ = try await sut(
            body: CodableModel.sample,
            queryParameters: ["key": "value"],
            pathKeysValues: ["username": "Google"]
        )

        // Then
        XCTAssertEqual(receivedUrlRequest.url?.absoluteString, "https://github.com/Google?key=value")
        XCTAssertEqual(receivedUrlRequest.httpMethod, "GET")
        XCTAssertEqual(receivedUrlRequest.httpBody, CodableModel.sampleData)
        XCTAssertEqual(receivedUrlRequest.allHTTPHeaderFields, [:])
    }

    func test_givenServiceCallerWithVoidBodyAndVoidResponse_whenGenerateRequest_thenAsCorrectUrlRquest() async throws {
        // Given
        var receivedUrlRequest: URLRequest!
        var requestInterceptor = RequestInterceptor<CodableModel>()
        requestInterceptor.runClosure = { receivedUrlRequest = $0 }
        requestInterceptor.runResultData = Data()

        let sut = Network<Void, Void>(
            url: "https://github.com/:username",
            method: .GET,
            headers: ["headerName": "headerValue"],
            requestInterceptor: requestInterceptor
        ).wrappedValue

        // When
        _ = try await sut(
            queryParameters: ["key": "value"],
            pathKeysValues: ["username": "Google"]
        )

        // Then
        XCTAssertEqual(receivedUrlRequest.url?.absoluteString, "https://github.com/Google?key=value")
        XCTAssertEqual(receivedUrlRequest.httpMethod, "GET")
        XCTAssertEqual(receivedUrlRequest.httpBody, nil)
        XCTAssertEqual(receivedUrlRequest.allHTTPHeaderFields, ["headerName": "headerValue"])
    }

    func test_givenServiceCallerWithVoidBodyAndDecodableResponse_whenGenerateRequest_thenAsCorrectResult() async throws {
        // Given
        var requestInterceptor = RequestInterceptor<CodableModel>()
        requestInterceptor.runResultData = CodableModel.sampleData

        let sut = Network<Void, CodableModel>(
            url: "https://github.com",
            method: .GET,
            requestInterceptor: requestInterceptor
        ).wrappedValue

        // When
        let result = try await sut()

        // Then
        XCTAssertEqual(result.data.name, CodableModel.sample.name)
        XCTAssertEqual(result.response.statusCode, 200)
    }

    func test_givenServiceCallerWithVoidBodyAndVoidResponse_whenGenerateRequest_thenAsCorrectResult() async throws {
        // Given
        var requestInterceptor = RequestInterceptor<Void>()
        requestInterceptor.runResultData = Data()

        let sut = Network<Void, Void>(
            url: "https://github.com",
            method: .GET,
            requestInterceptor: requestInterceptor
        ).wrappedValue

        // When
        let result = try await sut()

        // Then
        XCTAssertEqual(result.response.statusCode, 200)
    }

    struct RequestInterceptor<D>: DataNetworkRequestInterceptor {
        typealias DecodedType = D

        var runClosure: ((URLRequest) -> Void)?
        var runResultData: Data!
        var runUrlResponse: HTTPURLResponse = HTTPURLResponse(
            url: URL(string: "https://github.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        func intercept(_ request: inout URLRequest) async throws {}

        func runURLRequest(from request: URLRequest) async throws -> (Data, URLResponse) {
            runClosure?(request)

            return (runResultData, runUrlResponse)
        }
    }

}

// class SpyServiceCalling<Body, Response>: ServiceCalling {
//    var method: RetroSwift.HTTPMethod = .GET
//    var url: String = "https://github.com/"
//    var headers: [String : String] = [:]
//    var successStatusCodes: Set<Int> = Set<Int>(200 ... 209)
//    var requestInterceptor: NetworkRequestInterceptor = SpyNetworkInterceptor()
//
//    init() {}
//
//    func run(_ request: URLRequest) async throws -> NetworkResult<Data> {
//        let response = HTTPURLResponse(
//            url: URL(string: url)!,
//            statusCode: 200,
//            httpVersion: nil,
//            headerFields: nil
//        )!
//
//        return .init(response: response, data: CodableModel.sampleData)
//    }
//
//    struct SpyNetworkInterceptor: NetworkRequestInterceptor {
//        func intercept(_ request: inout URLRequest) async throws {}
//    }
// }
