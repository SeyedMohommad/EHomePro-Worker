//
//  RestingModeView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/30/24.
//

import SwiftUI

struct RestingModeView: View {
    var body: some View {
        VStack {
            Image("moon")
                .fixedSize()
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,height: 100 )
            Text("You are resting,If you want to see\nthe orders, change your status!")
                .fontWeight(.medium)
                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    RestingModeView()
}
