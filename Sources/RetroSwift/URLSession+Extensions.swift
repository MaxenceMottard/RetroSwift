//
//  URLSession+Extensions.swift
//  
//
//  Created by Maxence on 15/01/2022.
//

import Foundation

@available(iOS, deprecated: 15.0, message: "Use the built-in API instead")
extension URLSession {
    func dataAsync(from request: URLRequest) async throws -> (Data, URLResponse) {
//    func dataAsync(from request: URLRequest, _ caller: String = #function) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

//            task.taskDescription = caller
            task.resume()
        }
    }
}
