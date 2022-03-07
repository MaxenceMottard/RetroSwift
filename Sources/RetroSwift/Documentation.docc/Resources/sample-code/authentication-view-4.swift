//
//  AuthenticationView.swift
//
//
//  Created by Maxence on 08/03/2022.
//

import SwiftUI

struct AuthenticationView: View {
    private let authenticationService: AuthenticationService = AuthenticationService()

    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
        VStack {
            TextField("Enter your email", text: $email)
            SecureField("Enter your password", text: $password)

            Button("Login") {
                Task {
                    do {
                        let result = await authenticationService.login.call()
                    } catch (let error) {
                        print(error)
                    }
                }
            }
        }
    }
}

struct LoginBody: Encodable {
    let email: String
    let password: String
}
