//
//  StatusToggleView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/14/24.
//

import SwiftUI

struct StatusToggleView: View {
    @Binding var status:Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                
                
                // Song Title and Artist
                VStack(alignment: .leading) {
                    Text("Your status")
                }
                
                Spacer()
                
                // Playback Controls
                HStack(spacing: 20) {
                    Toggle(isOn: $status) {
                        Text("")
                    }
                    .labelsHidden()
                }
            }
            .padding()
            .background(Color(UIColor.systemGray5))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}


//#Preview {
//    StatusToggleView()
//}
