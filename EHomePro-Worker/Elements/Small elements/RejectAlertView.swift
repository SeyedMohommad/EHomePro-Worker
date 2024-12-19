//
//  RejectAlertView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 11/20/24.
//

import SwiftUI

struct RejectAlertView: View {
    @State private var showAlert = false
        
        var body: some View {
            Button("Show Alert") {
                showAlert = true
            }
            .alert("Reject Task", isPresented: $showAlert) {
                        
                Button("Add additional information") {
                            // button 1 action will come here
                        }
                        
                Button("Reject anyway", role: .destructive) {
                            // button 2 action will come here
                        }
                Button("Cancel", role: .cancel) {
                    // button 2 action will come here
                }
                    } message: {
                        Text("Do you want to reject the task entirely or provide additional information?")
                    }
                
    
            
//            .actionSheet(isPresented: $showAlert) {
//                ActionSheet(title: Text("Title"), message: Text("Choose one of this three:"), buttons: [
//                        .default(Text("First")) { },
//                        .default(Text("Second")) { },
//                        
//                        .cancel()
//                    ])
//            
//                
//
////                Alert(
////                    title: Text("Reject"),
////                    message: Text("Do you want to reject the task entirely or provide additional information?"),
////                    primaryButton: .default(Text("Cancel"), action: {
////                        // Cancel action
////                        print("Cancel")
////                    }),
////                    secondaryButton: .destructive(Text("Reject Anyway"), action: {
////                        // Reject
////                        print("Reject Anyway")
////                    }),
////                    
////                    
////                )
//            }
        }
}

#Preview {
    RejectAlertView()
}
