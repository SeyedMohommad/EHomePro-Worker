//
//  UserSmallPictureView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/28/24.
//

import SwiftUI

struct UserSmallPictureView: View {
    let imageName:String?
    let uiImage:UIImage?
    var body: some View {
        if (imageName != nil) {
            Image(imageName!)
                
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .foregroundColor(.black)
                .background(
                    Circle() // Capsule shape creates a rounded rectangle perfect for badges
                        .stroke(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")), lineWidth: 11)
                        .fill(Color.gray.opacity(0.1)) // Stronger orange color for the fill
                )
        }else{
            Image(uiImage: (uiImage ?? UIImage(systemName: "person.circle"))!)
                
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .foregroundColor(.black)
                .background(
                    Circle() // Capsule shape creates a rounded rectangle perfect for badges
                        .stroke(Color(uiColor: hexStringToUIColor(hex: "#E5E5E5")), lineWidth: 11)
                        .fill(Color.gray.opacity(0.1)) // Stronger orange color for the fill
                        
                )
        }
        
    }
}

#Preview {
    UserSmallPictureView(imageName: nil, uiImage: UIImage(systemName: "person.circle")!)
}
