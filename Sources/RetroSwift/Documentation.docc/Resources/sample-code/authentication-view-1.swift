//
//  AuthenticationView.swift
//  
//
//  Created by Maxence on 08/03/2022.
//

import SwiftUI

struct AuthenticationView: View {
    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
        VStack {
            TextField("Enter your email", text: $email)
            SecureField("Enter your password", text: $password)

            Button("Login") {}
        }
    }
}
