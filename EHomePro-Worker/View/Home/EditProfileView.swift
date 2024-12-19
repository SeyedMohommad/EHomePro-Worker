//
//  EditProfileView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/30/24.
//

import SwiftUI
import CustomTextField
import ExyteMediaPicker
import ImageViewer
import PhotosUI

struct EditProfileView: View {
    @State var image: UIImage?
    
    @State var worker:Worker?
    @State var workTypes:[WorkType]
    @State var selectedWorkTypes:[WorkerWorkType]
    @State var selectedWorkTypesTmp :[WorkerWorkType] = []
    
    @State private var name = ""
    @State private var id = 0
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var socialSecurity = ""
    @State private var iDCardPicture = ""
    @State private var defualtPrice = ""
    @State private var isLoading = false
    @State private var internalImageiDCard: UIImage?
    
    @StateObject private var imageViewModel = ImageViewModel()
    
    
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    @State private var isShowingImagePicker = false
    @State private var isShowingIdCard = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    //                    Spacer(minLength: 50) // Add space at the top
                    
                    WorkTypeCardsProfileView(workTypes: $workTypes, selectedWorkTypes: $selectedWorkTypes)
                    VStack(spacing: 20) {
                        UploadProfilePicView(image: $image,isLoading: $isLoading)
                        
                        VStack {
                            EGTextField(text: $name)
                                .setTitleText("Name")
                                .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                .setPlaceHolderText("Name")
                            EGTextField(text: $lastName)
                                .setTitleText("Last Name")
                                .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                .setPlaceHolderText("Last Name")
                            
                            EGTextField(text: $email)
                                .setTitleText("Email")
                                .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                .setPlaceHolderText("Email")
                            EGTextField(text: $phoneNumber)
                                .setTitleText("Phone Number")
                                .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                .setPlaceHolderText("Phone Number")
                                .keyboardType(.namePhonePad)
                            EGTextField(text: $socialSecurity)
                                .setTitleText("Social Security Number")
                                .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                .setPlaceHolderText("Social Security Number")
                                .keyboardType(.namePhonePad)
                            EGTextField(text: $defualtPrice)
                                .setTitleText("Please enter your default price (you can change this price when sending an offer for each order)")
                                .setTextColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                .setPlaceHolderText("Default price")
                                .keyboardType(.namePhonePad)
                            
                            ZStack {
                                if self.iDCardPicture == "" {
                                    HStack{
                                        Button(action: {
                                            // Present the document picker here
                                            isShowingImagePicker.toggle()
                                        }) {
                                            Image(systemName: "plus.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                            Text("Upload ID Card")
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                                                .frame(width: 326,height: 48)
                                        )
                                        .background(RoundedRectangle(cornerRadius: 15)
                                            .frame(width: 326,height: 48)
                                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#F2F2F2"))))
                                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                        
                                        .sheet(isPresented: $isShowingImagePicker) {
                                            ImagePickerView(image: $internalImageiDCard) // Pass the internalImage binding
                                            
                                        }
                                        .onChange(of: internalImageiDCard) { oldValue, newValue in
                                            self.isLoading = true
                                            guard let workerId = UserDefaults.standard.string(forKey: "WorkerId") else{
                                                return
                                            }
                                            UploadPictureService.shared.uploadIdCardImage(uiImage: newValue!, workerId: Int(workerId) ?? 0) { result in
                                                DispatchQueue.main.async {
                                                    self.isLoading = false
                                                    
                                                    switch result {
                                                    case .success:
                                                        
                                                        self.alertMessage = "image Uploaded successfully"
                                                        
                                                        
                                                    case .failure:
                                                        
                                                        self.alertMessage = "image Upload failed"
                                                        
                                                        
                                                        self.isShowingAlert = true
                                                    }
                                                }
                                            }
                                            
                                            
                                            
                                        }
                                    }
                                    .padding()
                                }else{
                                    // visit the Id card picture
                                    HStack {
                                        //
                                        
                                        Button(action: {
                                            // Present the document picker here
                                            isShowingImagePicker.toggle()
                                        }) {
                                            Text("Update your ID Card")
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                                                        .frame(width: 200,height: 48)
                                                )
                                                .background(RoundedRectangle(cornerRadius: 15)
                                                    .frame(width: 200,height: 48)
                                                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#F2F2F2"))))
                                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        Spacer()
                                            .frame(width: 5)
                                            .padding()
                                        
                                        
                                            .sheet(isPresented: $isShowingImagePicker) {
                                                ImagePickerView(image: $internalImageiDCard) // Pass the internalImage binding
                                                
                                            }
                                            .onChange(of: internalImageiDCard) { oldValue, newValue in
                                                self.isLoading = true
                                                guard let workerId = UserDefaults.standard.string(forKey: "WorkerId") else{
                                                    return
                                                }
                                                
                                                
                                                //                                        UploadPictureService.shared.uploadIdCardImage(uiImage: newValue!.getUIImage(newSize: CGSizeMake(100, 100))!, workerId: Int(workerId) ?? 0) { result in
                                                UploadPictureService.shared.uploadIdCardImage(uiImage: newValue!, workerId: Int(workerId) ?? 0) { result in
                                                    self.isLoading = false
                                                    switch result {
                                                    case .success:
                                                        DispatchQueue.main.async {
                                                            self.alertMessage = "image Uploaded successfully"
                                                            self.isShowingAlert = true
                                                        }
                                                    case .failure:
                                                        DispatchQueue.main.async {
                                                            self.alertMessage = "image Upload failed"
                                                            self.isShowingAlert = true
                                                        }
                                                    }
                                                }
                                                
                                                
                                                
                                            }
                                        
                                        //
                                        
                                        Button(action: {
                                            // Present the document picker here
                                            isShowingIdCard.toggle()
                                            imageViewModel.loadImage(fileName: iDCardPicture)
                                        }) {
                                            Image(systemName: "eye")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                                                        .frame(width: 40,height: 48)
                                                )
                                                .background(RoundedRectangle(cornerRadius: 15)
                                                    .frame(width: 40,height: 48)
                                                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#F2F2F2"))))
                                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                            
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        //                                        .padding()
                                        
                                        .sheet(isPresented: $isShowingIdCard) {
                                            if imageViewModel.isLoading {
                                                MyProgressView()
                                            }else{
                                                if let image = imageViewModel.image {
                                                    ImageViewer(image: .constant(Image(uiImage: image)) , viewerShown: self.$isShowingIdCard)
                                                }
                                                
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                    .padding()
                                }
                                
                            }
                            Button(action: {
                                
                                DispatchQueue.main.async {
                                    isLoading = true
                                    let worker = Worker(id: self.id, name: self.name, lastName: self.lastName, email: self.email, isVerified: nil, workerStatus: self.worker!.workerStatus, livingCity: self.worker!.livingCity, livingState: self.worker!.livingState , profilePicture: self.worker!.profilePicture, pricePerHour: Int(self.defualtPrice), socialSecurity: self.socialSecurity, phoneNumber: self.phoneNumber, idCardPicture: self.iDCardPicture)
                                    WorkerService.shared.updateWorkerData(worker: worker) { worker, error in
                                        
                                        
                                        
                                        isLoading = false
                                        if (error != nil) {
                                            
                                            alertMessage = error!.description
                                            
                                        } else {
                                            
                                            let removedWorkTypes = removedWorkTypes(from: selectedWorkTypesTmp, comparedTo: selectedWorkTypes)
                                            if !removedWorkTypes.isEmpty {
                                                for workerWorkType in removedWorkTypes {
                                                    if workerWorkType.id != nil {
                                                        WorkTypeService.shared.deleteWorkerWorkTypeById(id: workerWorkType.id!) { response in
                                                            switch response {
                                                            case .success(let success):
                                                                print("deleteWorkerWorkTypeById successfully")
                                                            case .failure(let error):
                                                                print(error.localizedDescription)
                                                                alertMessage = error.localizedDescription
                                                                self.isShowingAlert = true
                                                                break
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            lazy var selectedWorkTypesIds:[Int] = []
                                            for workType in selectedWorkTypes {
                                                
                                                selectedWorkTypesIds.append(workType.workTypeId)
                                                
                                            }
                                            if !selectedWorkTypesIds.isEmpty {
                                                WorkTypeService.shared.connectWorkTypesToWorker(workerID: self.id, workTypeIDs: selectedWorkTypesIds) { response in
                                                    switch response {
                                                    case .success(let success):
                                                        print("status code: \(success)")
                                                        alertMessage = "Your information was updated successfully"
                                                    case .failure(let error):
                                                        alertMessage = error.localizedDescription
                                                    }
                                                }
                                                
                                            }else{
                                                alertMessage = "Please Select your job!"
                                            }
                                        }
                                        self.isLoading = false
                                        isShowingAlert = true
                                    }
                                }
                            }, label: {
                                Text("Update information")
                                
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .frame(width: 308,height: 48)
                                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#3587E7")))
                                    }
                                    .padding()
                            })
                            
                            
                        }
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(.white)
                            .shadow(color: .gray, radius: 5, x: 0, y: 2)
                    )
                    .padding()
                    Spacer(minLength: 50) // Add space at the bottom
                }
                .frame(maxWidth: .infinity) // Ensure it takes up full width
                
            }
            
            if isLoading {
                MyProgressView()
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Update Profile"), message: Text(alertMessage))
        }
        .onAppear {
            selectedWorkTypesTmp = selectedWorkTypes
            if worker != nil {
                print(2)
                self.id = worker!.id
                self.email = worker!.email
                self.name = worker!.name
                self.lastName = worker!.lastName
                self.email = worker!.email
                self.socialSecurity = worker!.socialSecurity ?? ""
                self.phoneNumber = worker!.phoneNumber ?? ""
                self.iDCardPicture = worker?.idCardPicture ?? ""
                if worker!.pricePerHour != nil {
                    self.defualtPrice = "\(worker!.pricePerHour!)"
                }
                
                
            }else{
                
                //fetch worker
            }
            
            print("selected workTypes Id: \(selectedWorkTypes)")
            
            
        }
    }
    private func removedWorkTypes(from originalList: [WorkerWorkType], comparedTo newList: [WorkerWorkType]) -> [WorkerWorkType] {
        return originalList.filter { originalItem in
            !newList.contains { newItem in
                originalItem.workTypeId == newItem.workTypeId
            }
        }
    }
}

//#Preview {
//    EditProfileView()
//}

extension Image {
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)
            .clipped()
        return ImageRenderer(content: image).uiImage
    }
}


