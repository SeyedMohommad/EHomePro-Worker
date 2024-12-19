//
//  RegisterView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import SwiftUI
import CustomTextField

struct RegisterView: View {
    
    @State private var readyToNavigate:Bool = false
    @State private var verifyEmailAlert:Bool = false
    @State private var errorMessage:String?
    
    @StateObject private var newWorkerViewModel = NewWorkerViewModel()
    @StateObject private var loginVm = LoginViewModel()
    
    var body: some View {
        ScrollView {
            ZStack {
                
                if newWorkerViewModel.isLoading {
                    VStack {
                        
                        MyProgressView()
                            .ignoresSafeArea()
                            .zIndex(1)
                        Spacer()
                    }
                        
                }
                    
                NavigationLink(destination: LoginView(), isActive: $readyToNavigate) {
                    EmptyView()
                }

                VStack {
//                    Button {
//                        print("upload a pic")
//                        self.isShowingImagePicker = true
//                    } label: {
//
//                        UploadProfilePicView(image: image)
//                    }
//                    .sheet(isPresented: $isShowingImagePicker) {
//                        ImagePickerView(image: self.$image)
//                    }
          
                    VStack(spacing: 20) {
                        EGTextField(text: $newWorkerViewModel.name)
                            .setTitleText("Name")
                            .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                            .setPlaceHolderText("Name")
                        EGTextField(text: $newWorkerViewModel.lastName)
                            .setTitleText("Last Name")
                            .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                            .setPlaceHolderText("Last Name")
//                        EGTextField(text: $newWorkerViewModel.socialSecurity)
//                            .setTitleText("Social Security")
//                            .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
//                            .setPlaceHolderText("Social Security")
                        
                        EGTextField(text: $newWorkerViewModel.email)
                            .setTitleText("Email")
                            .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                            .setPlaceHolderText("Email")
                        EGTextField(text: $newWorkerViewModel.password)
                            .setTitleText("Password")
                            .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                            .setPlaceHolderText("Password")
                            .setSecureText(true)
                        if (self.errorMessage != nil) {
                            Text(self.errorMessage!)
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                        }
                    }
                    //                .frame(height: 328)
                    .padding()
                    Button(action: {
                        if newWorkerViewModel.name == "" || newWorkerViewModel.lastName == "" || newWorkerViewModel.email == "" || newWorkerViewModel.password == "" {
                            self.errorMessage = "Please fill the information"
                        }else{
                            newWorkerViewModel.createWorker { success, error in
                                
                                if success {
                                    
                                    self.verifyEmailAlert = true
                                    UserDefaults.standard.set(newWorkerViewModel.email, forKey: "email")
                                }else if error != nil {

                                    self.errorMessage = newWorkerViewModel.errorMessage
                                }
                                
                            }
                        }
                        
                    }, label: {
                        Text("Contiune")
                        
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: 308,height: 48)
                                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#3587E7")))
                            }
                            .padding()
                        
                    })
                    .alert(isPresented: $verifyEmailAlert, content: {
                        Alert(title: Text("Verify Email"), message: Text("Please check your Email inbox and verfy your email\nThen please log in and set up your account"), primaryButton: .default(Text("Ok"), action: {
                            self.readyToNavigate = true
                        }), secondaryButton: .default(Text("Resend it"), action: {
                            
                            newWorkerViewModel.createWorker { success, error in
                                if success {
                                    
                                    self.verifyEmailAlert = true
                                    UserDefaults.standard.set(newWorkerViewModel.email, forKey: "email")
                                }else if let error = error {
                                    
                                    self.errorMessage = newWorkerViewModel.errorMessage
                                }
                                
                            }
                            
                            //
                        }))
                        
                    })
                    
                    
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
                    
                }
                .blur(radius: newWorkerViewModel.isLoading ? 5:0)
                
            }
            
            .onTapGesture {
                hideKeyboard()
            }
            
            
        }
        
        
        
        
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//#Preview {
//    RegisterView()
//}

