//
//  VelocityLimitsService.swift
//
//
//  Created by You on 21/12/2021.
//

import Foundation
import RxSwift

public final class VelocityLimitsService: BaseService {
    public override class var serviceKey: ServiceKey { .velocityLimits }

    let jsonDecoder = JSONDecoder.default()

    required init(dataSource: DataSource, parameterEncoder: TopLevelEncoder, baseUrl: URL) {
        let url = baseUrl
            .appendingPathComponent("api")
            .appendingPathComponent("velocitylimits")
            .appendingPathComponent("v1")

        super.init(
            dataSource: dataSource,
            parameterEncoder: parameterEncoder,
            baseUrl: url
        )
    }

    public func get(_ cardId: String) -> Single<SpendingLimits> {
        let url = baseUrl.appendingPathComponent(cardId)
        let request = DataSourceRequest(
            url: url,
            method: .get
        )

        return self.dataSource
            .call(request: request) // DataSourceRequest => Data
            .decode(type: SpendingLimits.self, decoder: jsonDecoder) // Data => SpendingLimits
    }
}
