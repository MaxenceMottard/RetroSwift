//
//  VelocityLimitsService.swift
//
//
//  Created by You on 21/12/2021.
//

import Foundation

public final class VelocityLimitsService: BaseService {
    public override class var serviceKey: ServiceKey { .velocityLimits }

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
}
