//
//  WideButtonStyleView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 11/24/24.
//

import SwiftUI

struct WideButtonStyleView:View {
    let buttonText:String
    let buttonLogo:String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 320,height: 50)
                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#818CA1")))
            HStack {
                if buttonLogo != "" {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundColor(.white)
                }
                
                Text(buttonText)
                    .font(.system(size: 14,weight: .semibold))
                    .foregroundColor(.white)
            }
            
                
        }
    }
}
