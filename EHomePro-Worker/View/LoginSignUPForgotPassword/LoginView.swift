//
//  LoginView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import SwiftUI
import CustomTextField

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var alertMessage: String?
    @State private var isLoggedIn: Bool = false
        
    
    var body: some View {
        ScrollView {
            ZStack {
                if loginViewModel.isLoading {
                    MyProgressView()
                    
                }
                NavigationLink(destination: ContentView()
                    .navigationBarHidden(true), isActive: $loginViewModel.isLoggedIn) {
                    EmptyView()
                }


                VStack(spacing: 5) {
                    
                    VStack {
                        EGTextField(text: $loginViewModel.email)
                            .setTitleText("Enter your email")
                            .setPlaceHolderText("Email")
                            .padding(.horizontal)
                        
                        EGTextField(text: $loginViewModel.password)
                            .setTitleText("Please Enter your password")
                            .setPlaceHolderText("Password")
                            .setSecureText(true)
                            .padding(.horizontal)
                            .transition(.opacity)
                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("forgot password?")
                                .foregroundColor(.blue)
                        }
                        
                        .padding()
                        
                        if (self.alertMessage != nil) {
                            Text(self.alertMessage!)
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                        }
                        
                    }
                    .padding()
                    
                    
                    Button {
                        // login
                        if loginViewModel.email == "" || loginViewModel.password == "" {
                            self.alertMessage = "Please enter both username and password."
                        } else {
                            loginViewModel.login()
                            if loginViewModel.isLoggedIn {
                                self.isLoggedIn = true
                            }else{
                                
                                self.isLoggedIn = false
                            }
                        }
                    } label: {
                        Text("Login")
                            .font(.system(size: 12))
                            .frame(width: 310,height: 48)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: 310,height: 48)
                                    .foregroundColor(.blue)
                            }
                    }
                    
                    
                    
                    
                    
                    
                    
                    HStack{
                        Rectangle()
                            .frame(width: 140,height: 1)
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")))
                        Text("or")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(Color(uiColor: hexStringToUIColor(hex: "#979797"))))
                        Rectangle()
                            .frame(width: 140,height: 1)
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")))
                    }
                    .padding()
                    
                    VStack {
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Login with Google")
                                .foregroundColor(.black)
                        })
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 2)
                                .frame(width: 310,height: 42)
                            
                        }
                        .padding()
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Login with Apple")
                                .foregroundColor(.black)
                        })
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 2)
                                .frame(width: 310,height: 42)
                            
                        }
                        .padding()
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Login with meta")
                                .foregroundColor(.black)
                        })
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 2)
                                .frame(width: 310,height: 42)
                            
                        }
                        .padding()
                        
                    }
                    .padding()
                    Spacer()
                    
                    VStack {
                        Image("logo")
                            .resizable()
                            .frame(width: 80.0, height: 70)
                        Text("intelligentEhome".uppercased())
                            .font(.system(size: 13))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                    }
                    .padding(.bottom,0)
                    
                    .alert(isPresented: $loginViewModel.isErrorHappened) {
                        Alert(title: Text("Attention"), message: Text(loginViewModel.errorMessage))
                        
                    }
                    
                    
                }
                .blur(radius: loginViewModel.isLoading ? 5 : 0)
                .onTapGesture {
                    hideKeyboard()
            }
            }
        }
        .onAppear{
            if UserDefaults.standard.string(forKey: "refresh_token") != nil {
                loginViewModel.authenticateWithFaceID { success, error in
                    if success {
                        loginViewModel.login()
                    }else{
                        print("errors: \(error)")
                    }
                
                }
            }
        }
    }
    
    

    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


//#Preview {
//    LoginView()
//}
