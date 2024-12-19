//
//  FillInformationView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/30/24.
//

import SwiftUI

struct FillInformationView: View {
    var body: some View {
        VStack{
            Image("profile-tick")
                .fixedSize()
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,height: 100 )
            Text("To view orders, \nfirst complete your information")
                .fontWeight(.medium)
                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                .multilineTextAlignment(.center)
            
            Button {
                // view Profile
            } label: {
                Text("View Profile")
            }
            .padding()

        }
    }
}

#Preview {
    FillInformationView()
}
