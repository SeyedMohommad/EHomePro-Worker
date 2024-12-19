//
//  ForgotPasswordView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import SwiftUI
import CustomTextField

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ResetPasswordViewModel()
    @State private var email: String = ""
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                MyProgressView()
            }
            VStack {
                EGTextField(text: $email)
                    .setTitleText("Enter your email")
                    .setPlaceHolderText("Email")
                    .padding(.horizontal)
                
                Button(action: {
                    
                    viewModel.resetPassword(email: email)
                }, label: {
                    Text("Send Reset Password Link")
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
                })
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
            }
            
            .padding()
            
            
        }
        .onTapGesture {
            
            hideKeyboard()
        }
        
        .alert(isPresented: $viewModel.isRequestFinished, content: {
            if viewModel.errorMessage != nil{
                Alert(title: Text("Error"),message: Text(viewModel.errorMessage!))
            }else{
                Alert(title: Text("Attention"),message: Text("The reset link has been sent \n Please check your inbox"))
            }
            
        })
        
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ForgotPasswordView()
}

