//
//  DocumentUploaderView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 11/24/24.
//

import SwiftUI
import UIKit

struct DocumentUploaderView: View {
    @Binding var images: [Image] // For display
    @Binding var imageDatas: [Data] // For upload
    @State private var internalUIImage: UIImage?
    @State private var isShowingImagePicker = false

    var body: some View {
        VStack {
            ZStack {
                Button(action: {
                    isShowingImagePicker.toggle()
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text("Upload relevant documents")
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                        .frame(width: 326, height: 48)
                )
                .background(RoundedRectangle(cornerRadius: 15)
                    .frame(width: 326, height: 48)
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#F2F2F2"))))
                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
            }

            HStack {
                if images.isEmpty {
                    ForEach(0..<5, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                            .frame(width: 45, height: 45)
                            .background(RoundedRectangle(cornerRadius: 16)
                                .frame(width: 45, height: 45)
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#F2F2F2"))))
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                    }
                } else {
                    ForEach(0..<images.count, id: \.self) { index in
                        ZStack {
                            images[index]
                                .resizable()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: 45, height: 45)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [10, 5]))
                                        .frame(width: 48, height: 48)
                                        .background(RoundedRectangle(cornerRadius: 16)
                                            .frame(width: 45, height: 45)
                                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#F2F2F2"))))
                                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                }
                        }
                        .onTapGesture {
                            images.remove(at: index)
                            imageDatas.remove(at: index) // Ensure data is also removed
                            isShowingImagePicker.toggle()
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $isShowingImagePicker, content: {
            if images.count < 5 {
                ImagePickerView(image: $internalUIImage)
                    .onDisappear {
                        isShowingImagePicker = false
                        if let uiImage = internalUIImage {
                            // Convert UIImage to SwiftUI Image
                            let swiftUIImage = Image(uiImage: uiImage)
                            images.append(swiftUIImage)
                            // Store original image data
                            if let imageData = uiImage.pngData() { // Use PNG to retain original size
                                imageDatas.append(imageData)
                            }
                        }
                    }
            } else {
                Text("The limit of the selected image is 5 images")
            }
        })
    }
}

//#Preview {
//    DocumentUploaderView()
//}
