//
//  ContentView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 1
    
    @State var isOpenSideMenu: Bool = false
    @State var isStillLoggedIn: Bool = false
    
    @State var isNotLoggedIn: Bool = true
    
    
    
    var body: some View {
        NavigationView {
        ZStack {
            TabView(selection: $selectedTab) {
                
//                    ZStack {
//                        VStack {
                            HomeView()
                            
                            
                            
//                        }
//                        
//                    }
                    .navigationBarItems(leading: Button(action: {
                        //                        self.isOpenSideMenu.toggle()
                    }, label: {
                        Image(systemName: "list.bullet")
                    }) , trailing: Button(action: {
                        //                        self.isNotLoggedIn = true
                    }, label: {
                        Image(systemName: "bell")
                    }))
                    
                    .navigationBarTitleDisplayMode(.inline)
                    
                    
                    .tabItem { Label("Home",image: selectedTab == 1 ? "home.fill":"home") }
                    .tag(1)
//                    NavigationView {
                        EmptyView()
                            .navigationBarItems(leading: Button(action: {
                                //                            self.isOpenSideMenu.toggle()
                                
                            }, label: {
                                Image(systemName: "list.bullet")
                            }) , trailing:Image(systemName: "bell") )
                        
//                    }
                    .tabItem { Label("Activities",image: selectedTab == 2 ? "activity.fill":"activity") }
                    .tag(2)
                    
                    ChatListView()
                        .navigationBarItems(leading: Button(action: {
                            //                            self.isOpenSideMenu.toggle()
                            
                        }, label: {
                            Image(systemName: "list.bullet")
                        }) , trailing:Image(systemName: "bell") )
                    
                        .tabItem { Label("Messanger",image: selectedTab == 3 ? "messages.fill":"messages") }
                        .tag(3)
                    
//                    NavigationView {
                        ProfileView()
                            .navigationBarTitle("Profile", displayMode: .inline)
                            .navigationBarItems(leading: Button(action: {
                                //                            self.isOpenSideMenu.toggle()
                                
                            }, label: {
                                Image(systemName: "list.bullet")
                            }) , trailing:Image(systemName: "bell") )
//                    }
                    .tabItem { Label("Profile",image: selectedTab == 4 ? "profile-circle.fill":"profile-circle") }
                    .tag(4)
                }
                .shadow(color: .gray, radius: 5, x: 0, y: 2)
            }
        }
        
        .onAppear{
            if (UserDefaults.standard.string(forKey: "refresh_token") != nil) {
                WorkerService.shared.fetchWorkerDatabyEmail { worker, error in
                    if error != nil {
                        AuthenticationService.shared.refreshToken { success in
                            if success {
                                self.isNotLoggedIn = true
                            }
                        }
                    }else{
                        // fetch current orders and pooling for orders
                    }
                }
            }
            
            
        }
    }
}

#Preview {
    ContentView()
}


