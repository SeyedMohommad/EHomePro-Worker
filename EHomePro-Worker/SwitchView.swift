//
//  SwitchView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import SwiftUI

struct SwitchView: View {
    
    @State private var isLoggedIn: Bool = UserDefaults.standard.string(forKey: "refresh_token") != nil
    @State private var isTokenRevoked: Bool = false
    
    
    var body: some View {
        NavigationView {
            ZStack{
                NavigationLink(destination: ContentView()
                    .navigationBarHidden(true), isActive: $isTokenRevoked) {
                    EmptyView()
                }
                if isLoggedIn {
                    MyProgressView()
                        .onAppear {
                            AuthenticationService.shared.refreshToken { success in
                                print(success)
                                self.isTokenRevoked = success
                                
                                self.isLoggedIn = success
                            }
                        }
                } else {
                    LoginSignUpView()
//                    LoginSignUpView(isNotLoggedIn: $isLoggedIn)
                }
            }
        }
        
    }
}

#Preview {
    SwitchView()
}
