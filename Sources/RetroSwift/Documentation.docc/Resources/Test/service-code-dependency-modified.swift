//
//  Dependencies+Services.swift
//  Core
//
//  Created by Clément Nonn on 14/06/2021.
//

import Foundation
import Swinject

extension Dependencies {
    /// The assembler to assemble everything
    public static let assembler = Assembler([
        ServicesAssembly(
            services: [
                // Insert Services here
                VelocityLimitsService.self,
                CardService.self,
                OperationsService.self,
                RestrictionsService.self,
                SpendingLimitsService.self,
                ContactInfoService.self,
                MerchantBlockingService.self,
                CountriesService.self,
                KeycloakAuthService.self,
                OpenIdService.self,
                CustomersService.self
            ]
        )
    ], parent: staticServices)
}
