//
//  LoginSignUpView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import SwiftUI


struct LoginSignUpView: View {
    
    @State private var hasProfile: Bool = false // change it in request response
    @State private var selectionMode: String = "login"
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                
                
                VStack(spacing:30) {
                    Picker("", selection: $selectionMode) {
                        Text("Login").tag("login")
                        Text("Register").tag("register")
                    }
                    
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 358,height: 60)
                    
                    .padding()
                    if selectionMode == "login" {
                        LoginView()
                    }else{
                        RegisterView()
                    }
                    
                    
                    
                }
                
            }
            
            
            
        }
        
    }
    
    
    
    
}

