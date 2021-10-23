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

struct RegisterView: View {
    @State var emailAddress: String = ""
    @State var password: String = ""
    @ObservedObject private var api: UserApi = UserApi()
    
    var body: some View {
        VStack {
            Text(String("Blue Eagle"))
                .font(.largeTitle)
            Section() {
                TextField("email", text: $emailAddress)
                    .frame(width: 280)
                SecureField("Password", text: $password)
                    .frame(width: 280)
                SecureField("Confirm Password", text: $password)
                    .frame(width: 280)
                
            } header: {
                Text("Registration")
            }
            .padding()
            if(self.api.registrationFailed) {
                Text("Registration Failed")
            }
            HStack {
                Button(action: {
                    api.createAccount(
                        email: emailAddress,
                        password: password,
                        completion: { (user) in
                            print("DUDE \(user)")
                        })
                    
                }) {
                    Text("Register")
                }.padding()
                
            }
            .padding(20)
        }
    }
    
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
