//
//  UploadProfilePicView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/30/24.
//

import SwiftUI

struct UploadProfilePicView: View {
    @Binding var image: UIImage?
    @Binding var isLoading:Bool
    
    @State private var internalImage: UIImage?
    @State private var isShowingImagePicker = false
    
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    
    init(image: Binding<UIImage?>, isLoading: Binding<Bool>) {
        self._image = image
        self._internalImage = State(initialValue: image.wrappedValue)
        self._isLoading = isLoading
    }
    
    var body: some View {
        ZStack {
            if let internalImage = internalImage {
                Image(uiImage: internalImage)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 110, height: 110)
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")))
                Circle()
                    .stroke(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")), lineWidth: 5)
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#F9F9F9")))
            } else {
                Circle()
                    .stroke(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")), lineWidth: 5)
                    .frame(width: 120, height: 120)
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#F9F9F9")))
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")))
            }
            
            Button {
                isShowingImagePicker.toggle()
            } label: {
                ZStack {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#3587E7")))
                        .background(
                            Circle()
                                .fill(Color(uiColor: hexStringToUIColor(hex: "#3587E7")).opacity(0.2))
                        )
                    Circle()
                        .fill(Color(uiColor: hexStringToUIColor(hex: "#3587E7")).opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                }
                .padding(.top, 100)
                .padding(.leading, 100)
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePickerView(image: self.$internalImage) // Pass the internalImage binding
                    .onDisappear {
                        if let newImage = internalImage {
                            guard let workerId = UserDefaults.standard.string(forKey: "WorkerId") else {
                                return
                            }
                            isLoading = true
                            UploadPictureService.shared.uploadProfileImage(uiImage: newImage, workerId: Int(workerId) ?? 0) { result in
                                isLoading = false
                                switch result {
                                    
                                case .success:
                                    self.alertMessage = "image Uploaded successfully"
                                    self.isShowingAlert = true
                                    print(result)
                                case .failure:
                                    self.alertMessage = "image Upload failed"
                                    self.isShowingAlert = true

                                    print(result)
                                }
                            }
                        }
                    }
                    .alert(isPresented: $isShowingAlert) {
                        Alert(title: Text("Profile Picture"),message: Text(self.alertMessage))
                    }
            }
            
        }
    }
}
