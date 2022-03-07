//
//  AuthenticationService.swift
//
//
//  Created by Maxence on 08/03/2022.
//

import Foundation
import RetroSwift

class AuthenticationService {

    @Network<Void>(url: "https://api.domain.ext/auth", method: .POST)
    var login

}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
