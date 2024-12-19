//
//  ProfileView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/30/24.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var imageViewModel = ImageViewModel()
    @ObservedObject var loginViewModel = LoginViewModel()
    
    @State private var isLogedOut = false
    @State private var isLoading = false
    
    @State private var profImage: UIImage?
    
    @State private var worker:Worker?
    @State private var workTypes:[WorkType] = []
    @State private var selectedWorkTypes:[WorkerWorkType] = []
    
    var body: some View {
        
        ZStack {
            NavigationLink(destination: SwitchView()
                .navigationBarHidden(true), isActive: $isLogedOut) {
                EmptyView()
            }

            VStack {
                HStack {
                    if let savedWorkerData = UserDefaults.standard.data(forKey: "Worker"),
                        let savedWorker = try? JSONDecoder().decode(Worker.self, from: savedWorkerData) {
                        // Use savedCustomer
                        
                        HStack(spacing:10) {
                            if let image = imageViewModel.image {
                                
                                UserSmallPictureView(imageName: nil, uiImage: image)
                                    .onAppear{
                                        self.profImage = image
                                    }
//                                Image(uiImage: image)
//                                    .resizable()
//                                    .frame(width: 40.0, height: 40.0)
                                HStack {
                                    Text("\(savedWorker.name) \(savedWorker.lastName)")
                                        .font(.system(size: 16))
                                    .fontWeight(.medium)
                                }
                                
                            }else{
                                
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 40.0, height: 40.0)
                                Text(savedWorker.name)
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                Text(savedWorker.lastName)
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                            }
                            
                        }
                        .padding()
                    } else {
                        // Handle decoding failure or absence of saved data
                        HStack(spacing:5) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                            Text("Error")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                            Text("Error")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        .padding()
                    }

                    
                    
                    Spacer()

                    
                    NavigationLink(destination: EditProfileView(image: profImage,worker: self.worker,workTypes: workTypes, selectedWorkTypes: selectedWorkTypes)
                        .navigationBarTitle("Edit Profile",displayMode: .inline)) {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                        .frame(width: 16,height: 16)
                                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#E7AA35")))
                                    Text("Edit Profile")
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#E7AA35")))
                                }
                                .frame(width: 120, height: 40)
                                .background(Color(uiColor: hexStringToUIColor(hex: "#E7AA35")).opacity(0.12))
                                .background(content: {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Color(uiColor: hexStringToUIColor(hex: "#E7AA35")), lineWidth:1)
                                        .frame(width: 120, height: 40)
                                    //                            .background(Color.white)
                                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#E7AA35")))
                                    
                                })
                                .padding()
                        }


                    
                }
                .frame(width: 358,height: 77)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: 358,height: 77)
                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                }
                
                VStack {
                    NavigationLink {
                        Text("Wallet")
                    } label: {
                        HStack {
                            Image("wallet")
                            Text("Wallet")
                                .fontWeight(.bold)
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                            Spacer()
                        }
                        .padding()
                    }

                    
                    Divider()
                        .frame(width: 300)
                    NavigationLink {
//                        AddrressListView()
                        EmptyView()
                            .navigationTitle("Your activities")
                    } label: {
                        HStack {
                            Image("setting-2")
                            Text("Your activities")
                                .fontWeight(.bold)
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                            Spacer()
                        }
                        .padding()
                    }

                    
                    
                    Divider()
                        .frame(width: 300)
                        
                    Button(action: {
                        DispatchQueue.main.async {
                            
                        
                        isLoading = true
                        loginViewModel.logout { result in
                            isLoading = false
                            switch result {
                            case .success :
                                isLogedOut = true
                            case .failure(_):
                                isLogedOut = false
                            }
                        }
                    }
                    }, label: {
                        HStack {
                            Image("logout")
                            Text("Logout")
                                .fontWeight(.bold)
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                            Spacer()
                        }
                        .padding()
                    })
                    
                    
                    
                }
                .frame(width: 358,height: 230)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: 358,height: 225)
                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                }
                Spacer()
                
            }
            if imageViewModel.isLoading || isLoading {
                
                MyProgressView()
                    .onAppear{
                        print("isLoading: \(isLoading)")
                        print("imageViewModel.isLoading: \(imageViewModel.isLoading)")
                    }
            }
        }
        .onAppear{
            isLoading = true
            WorkerService.shared.fetchWorkerDatabyEmail { worker, error in
                self.isLoading = false
                if ((worker?.profilePicture) != nil) {
                    imageViewModel.loadImage(fileName: worker!.profilePicture!)
                }else{
                    
                }
                
            }
            
            loadProfileData()
            
//            DispatchQueue.main.async {
//                if let savedCustomerData = UserDefaults.standard.data(forKey: "Customer"),
//
//                   let savedCustomer = try? JSONDecoder().decode(Customer.self, from: savedCustomerData) {
//
//
//
//
//                }else{
//                    print(789)
//                }
//            }
            
        }
        .fullScreenCover(isPresented: $isLogedOut) {
            LoginSignUpView()
        }
    }
    
    private func loadProfileData() {
        DispatchQueue.main.async {
        WorkerService.shared.fetchWorkerDatabyEmail { worker, error in
            isLoading = true
                if let worker = worker {
                    self.worker = worker
                    
                    WorkTypeService.shared.fetchAllWorkTypes { response in
                        switch response {
                        case .success(let workTypes):
                            self.workTypes = workTypes
                            WorkTypeService.shared.fetchWorkerWorkTypes(workerID: worker.id) { response in
                                DispatchQueue.main.async {
                                    switch response {
                                    case .success(let workerWorkTypes):
                                        self.isLoading = false
                                        self.selectedWorkTypes = workerWorkTypes
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        case .failure(let error):
                            print("fetchAllWorkTypes")
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    print(error ?? "Unknown error")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
