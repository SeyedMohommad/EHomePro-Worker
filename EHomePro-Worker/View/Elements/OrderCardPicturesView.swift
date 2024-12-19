//
//  OrderCardPicturesView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/6/24.
//

import SwiftUI

struct OrderCardPicturesView: View {
   
    @Binding var isLoading:Bool
    
    @Binding var orderPictures:[UIImage]
    
    @StateObject private var imageViewModel = ImageViewModel()
    
    var body: some View {
        HStack {
            
            if orderPictures.isEmpty {
                
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
                
                OrderPictureView(orderPictures: $orderPictures)
                
            }
            
        }
        .onChange(of: orderPictures) { oldValue, newValue in
            if newValue == oldValue {
                print("noting has been changed")
            }else{
                print("orderPic : OldValue \(oldValue), newValue \(newValue)")
            }
            
        }
    }
}

//#Preview {
//    OrderCardPicturesView()
//}
