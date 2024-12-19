//
//  OrderCardView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/28/24.
//

import SwiftUI

struct OrderCardView: View {
    
    let order:Order
    @State private var customer:Customer = Customer(id: 0, name: "", lastName: "", phoneNumber: "", email: "", profilePicture: "")
    @StateObject var imageViewModel = ImageViewModel()
    
    @Binding var isLoading:Bool
    var body: some View {
        
        VStack {
            HStack {
                
                if !imageViewModel.isLoading && customer.profilePicture != "" {
                    
                    UserSmallPictureView(imageName: nil, uiImage: imageViewModel.image)
                    
                }else{
                    UserSmallPictureView(imageName: nil, uiImage: nil)
                }
                
                
                HStack(spacing: 2,content: {
                    Text(customer.name)
                        .font(.system(size: 20,weight: .semibold))
                    Text(customer.lastName)
                        .font(.system(size: 20,weight: .semibold))
                })
                Spacer()
                
            }
            Divider()
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(.gray)
                Text("Whats wrong? \(order.title ?? "")")
                    .font(.system(size: 12,weight: .medium))
                
                Spacer()
            }.foregroundColor(.gray)
            Divider()
            HStack(spacing: 2) {
                Image(systemName: "calendar")
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "979797")))
                Text(formatDateAndTime(from: order.dateAndTime).date)
                    .font(.system(size: 14,weight: .bold))
                Spacer()
                Image(systemName: "clock")
                    
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "979797")))
                Text(formatDateAndTime(from: order.dateAndTime).time)
                    .font(.system(size: 14,weight: .bold))
            }
            Divider()
            
            NavigationLink {
                OrderDetailsView(order:order,customer: customer, customerProfilePicture: imageViewModel.image)
                    
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 320,height: 50)
                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#818CA1")))
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(.white)
                        Text("Details")
                            .font(.system(size: 14,weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                        
                }
                
            }
            
            
        }
        .padding()
        .background(content: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .shadow(color: .gray, radius: 5, x: 0, y: 2)
        })
        .onAppear{
            DispatchQueue.main.async {
                isLoading = true
            }
            
            CustomerService.shared.getCustomer(by: order.customerId) { customer in
                DispatchQueue.main.async {
                    isLoading = false
                }
                do {
                    self.customer = try customer.get()
                    
                    //                    if try customer.get().profilePicture != nil {
                    //                        ImageService.shared.loadImage(fileName: try customer.get().profilePicture!)
                    //                    }else{
                    //                        print(123)
                    //                    }
                    
                }catch {
                    print("Error getCustomer")
                }
                
            }
        }
        .onChange(of: customer) { oldValue, newValue in
            imageViewModel.loadImage(fileName: newValue.profilePicture!)
        }
    }
    
    
    
    
}

//#Preview {
//    OrderCardView(order:)
//}
