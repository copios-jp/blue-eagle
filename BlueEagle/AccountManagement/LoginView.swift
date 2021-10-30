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
    enum Field {
        case emailAddress
        case password
    }
    
    @State var emailAddress: String = ""
    @State var password: String = ""
    @State var isLoading: Bool = false
    @State var loginFailed: Bool = false
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject var userController: UserController
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .zIndex(1)
            }
            VStack {
                if(loginFailed) {
                    Text("login-failed")
                        .foregroundColor(.red)
                }
                Section() {
                    TextField("email", text: $emailAddress)
                        .frame(width: 280)
                        .focused($focusedField, equals: .emailAddress)
                        .textContentType(.emailAddress)
                        .submitLabel(.next)
                        .disabled(isLoading)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField(String(localized:"password"), text: $password)
                        .frame(width: 280)
                        .focused($focusedField, equals: .password)
                        .textContentType(.password)
                        .submitLabel(.next)
                        .disabled(isLoading)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .onSubmit {
                    switch focusedField {
                    case .emailAddress:
                        if(password.isEmpty) {
                            focusedField = .password
                        }
                    case .password:
                        if(emailAddress.isEmpty) {
                            focusedField = .emailAddress
                        }
                    default: break
                    }
                    if(!password.isEmpty && !emailAddress.isEmpty) {
                        isLoading = true
                        Task {
                            do {
                                try await userController.signin(email: emailAddress, password: password )
                            } catch {
                                loginFailed = true
                                isLoading = false
                                focusedField = .emailAddress
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
