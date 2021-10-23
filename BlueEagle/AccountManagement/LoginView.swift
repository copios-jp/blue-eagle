//
//  LoginView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/03.
//
/*
 
 App starts by first looking for a stored session/account
 if there is one, go to the heart rate view
 
 if not - you login or create and account here
 
 
 */

import SwiftUI


struct LoginView: View {
    @State var emailAddress: String = ""
    @State var password: String = ""
    @State var loginFailed: Bool = false
    
    @EnvironmentObject var userController: UserController
    var body: some View {
        VStack {
            Text(String("Blue Eagle"))
                .font(.largeTitle)
            Section() {
                TextField("email", text: $emailAddress)
                    .frame(width: 280)
                SecureField("Password", text: $password)
                    .frame(width: 280)
                
            } header: {
                Text("Let's get started")
            }
            .padding()
            if(loginFailed) {
                Text("Login Failed")
            }
            HStack {
                Button {
                    Task {
                     try await loginFailed = !userController.authenticate(email: emailAddress, password: password )
                        
                    }
                } label:  { Text("Sign In").padding() }
                
            }
            .padding(20)
            Spacer()
            VStack {
                Text(String("Don't have an account yet?"))
                    .padding()
                Button(action: { print("register")}) {
                    Text("Register now")
                }
            }
            Spacer()
            
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
