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
        if #available(iOS 15, *) {
            return try await self.data(for: request)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data, let response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }

                continuation.resume(returning: (data, response))
            }

            task.resume()
        }
    }
}
