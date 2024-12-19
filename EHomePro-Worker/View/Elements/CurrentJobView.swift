//
//  OrderCardView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/28/24.
//

import SwiftUI

struct CurrentJobView: View {
    let tenderOffer:(offer: TenderOffer, customer:Customer, order:Order?)
    
    @State private var isAlertShowing = false
    @State private var alertMessage = ""
    
    @StateObject private var imageViewModel = ImageViewModel()
    @StateObject private var roomViewModel = RoomViewModel()
    var body: some View {
        VStack {
            HStack {
                if imageViewModel.isLoading {
                    UserSmallPictureView(imageName: nil, uiImage: UIImage(systemName: "person.circle")!)
                }else{
                    UserSmallPictureView(imageName: nil, uiImage: imageViewModel.image)
                }
                
                HStack(spacing: 2, content: {
                    Text(tenderOffer.customer.name)
                        .font(.system(size: 20,weight: .semibold))
                    Text(tenderOffer.customer.lastName)
                        .font(.system(size: 20,weight: .semibold))
                })
                
                Spacer()
                HStack(spacing:2) {
                    Button(action: {
                        // Action for the button
                        if tenderOffer.offer.tenderOfferStatus == .accepted ||  tenderOffer.offer.tenderOfferStatus == .acceptedSecondTry || tenderOffer.offer.tenderOfferStatus == .inAction {
                            
                            UIApplication.shared.open(URL(string: "tel://\(tenderOffer.customer.phoneNumber)")!)
                        }else{
                            
                            alertMessage = "You cannot contact the customer before accepting your offer!"
                            isAlertShowing = true
                        }
                        

                    }) {
                        Image(systemName: "phone") // Using a system icon for simplicity
                            .font(.title) // Adjust the size as needed
                            .foregroundColor(Color.gray) // Adjust the color as needed
                            .padding() // Padding around the icon
                            .background(
                                RoundedRectangle(cornerRadius: 10) // Rounded rectangle shape
                                    .fill(Color(UIColor.systemGray6)) // Adjust the fill color as needed
                                    .shadow(radius: 3) // Adjust the shadow as needed
                                    .frame(width: 40,height: 40)
                            )
                        
                    }
                    Button(action: {
                        // Action for the button
                        if tenderOffer.offer.tenderOfferStatus == .accepted ||  tenderOffer.offer.tenderOfferStatus == .acceptedSecondTry || tenderOffer.offer.tenderOfferStatus == .inAction {
                            // making room and start messaging
                        }else{
                            alertMessage = "You cannot contact the customer before accepting your offer!"
                            isAlertShowing = true
                        }
                        
                    }) {
                        Image(systemName: "message") // Using a system icon for simplicity
                            .font(.title) // Adjust the size as needed
                            .foregroundColor(Color.gray) // Adjust the color as needed
                            .padding() // Padding around the icon
                            .background(
                                RoundedRectangle(cornerRadius: 10) // Rounded rectangle shape
                                    .fill(Color(UIColor.systemGray6)) // Adjust the fill color as needed
                                    .shadow(radius: 3) // Adjust the shadow as needed
                                    .frame(width: 40,height: 40)
                            )
                        
                    }
                }
                
            }
            Divider()
            
            HStack {
                HStack(spacing: 2 , content: {
                    
                    Text("$")
                        .font(.system(size: 20,weight: .bold))
                    Text(String(format: "%.2f", tenderOffer.offer.price))
                        .font(.system(size: 20,weight: .bold))
                    
                })
                Spacer()
                switch tenderOffer.offer.tenderOfferStatus {
                case .created:
                    StatusView(status: .waiting)
                case .createdSecondTry:
                    StatusView(status: .waiting)
                case .accepted:
                    StatusView(status: .accepted)
                case .acceptedSecondTry:
                    StatusView(status: .accepted)
                case .inAction:
                    StatusView(status: .waiting)
                case .canceled:
                    StatusView(status: .canceled)
                case .done:
                    StatusView(status: .done)
                }
                
            }
            Divider()
            HStack(spacing: 2) {
                Image(systemName: "calendar")
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "979797")))
                Text(formatDateAndTime(from: tenderOffer.order!.dateAndTime).date)
                    .font(.system(size: 14,weight: .bold))
                Spacer()
                Image(systemName: "clock")
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "979797")))
                Text(formatDateAndTime(from: tenderOffer.order!.dateAndTime).time)
                    .font(.system(size: 14,weight: .bold))
            }
        }
        .padding()
        .background(content: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .shadow(color: .gray, radius: 5, x: 0, y: 2)
        })
        .alert(isPresented: $isAlertShowing, content: {
            Alert(title: Text("Offer Status"),message: Text(alertMessage))
        })
        .onAppear{
           
            if let profilePicture = tenderOffer.customer.profilePicture {
                imageViewModel.loadImage(fileName: profilePicture)
            }
            
        }
    }
    
}
//
//#Preview {
//    CurrentJobView()
//}
