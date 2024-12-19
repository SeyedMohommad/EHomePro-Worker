//
//  OrderPictureView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/12/24.
//

import SwiftUI
import ImageViewer


struct OrderPictureView: View {
    @Binding var orderPictures: [UIImage]
    @State private var isImageShowing: Bool = false
    @State private var selectedImage: Image?

    var body: some View {
        ZStack {
            HStack {
                ForEach(0..<orderPictures.count, id: \.self) { index in
                    Image(uiImage: orderPictures[index])
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
                        .onTapGesture {
                            self.selectedImage = Image(uiImage: orderPictures[index])
                            isImageShowing.toggle()
                        }
                }
            }
            
        }
        
        .fullScreenCover(isPresented: $isImageShowing,content: {
            EmptyView()
                .overlay(ImageViewer(image: $selectedImage, viewerShown: $isImageShowing))
        })
    }
}
//
//#Preview {
//    OrderPictureView()
//}
