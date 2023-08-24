//
//  CodableModel.swift
//  
//
//  Created by Maxence Mottard on 24/08/2023.
//

import Foundation

// swiftlint:disable force_try
struct CodableModel: Codable {
    let name: String

    static let sample: Self = .init(name: "Sample")
    static let sampleData: Data = try! JSONEncoder().encode(sample)
}
// swiftlint:enable force_try
