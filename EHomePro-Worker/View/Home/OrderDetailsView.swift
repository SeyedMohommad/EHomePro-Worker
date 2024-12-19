//
//  OrderDetailsView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/15/24.
//

import SwiftUI
import CustomTextField
import ImageViewer

struct OrderDetailsView: View {
    let order:Order
    let customer:Customer
    let customerProfilePicture:UIImage?
    @State private var customerAddress:Address?
    @State private var hasAdditionalInfo:Bool = false
    @State private var description:String = ""
    @State private var price = ""
    @State private var orderPictures:[UIImage] = []
    
    @StateObject var locationManager = LocationManager()
    
    @State private var alertMessage:String = ""
    @State private var alertShowing:Bool = false
    @State private var isLoading:Bool = false
    @State private var isOfferCreated:Bool = false
    @State private var isWorkerSure:Bool = false
    @State private var isErrorAlerShowing:Bool = false

    @State private var offer:TenderOffer?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject private var orderPictureViewModel = OrderPicturesViewModel()
    @StateObject private var imageViewModel = ImageViewModel()
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack {
                        VStack {
                            Spacer()
                                .frame(height: 20)
                            HStack {
                                UserSmallPictureView(imageName: nil, uiImage: customerProfilePicture)
                                
                                Text(customer.name)
                                    .font(.system(size: 20, weight: .semibold))
                                Text(customer.lastName)
                                    .font(.system(size: 20, weight: .semibold))
                                Spacer()
                            }
                            .padding()
                            Divider()
                            
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "doc.plaintext")
                                Text("Whats wrong?")
                                    .font(.system(size: 15,weight: .medium))
                                    .foregroundColor(.gray)
                                if let title = order.title {
                                    Text(order.title!)
                                        .font(.system(size: 15,weight: .medium))
                                        .foregroundColor(.gray)
                                }else{
                                    Text("title is null")
                                }
                                
                                Spacer()
                            }
                            .padding()
                            Divider()
                            HStack(alignment: .firstTextBaseline) {
                                Image(systemName: "doc.plaintext")
                                
                                Text(order.description)
                                    .font(.system(size: 15,weight: .medium))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding()
                            Divider()
                            HStack(spacing: 2) {
                                Text("Schedule:")
                                    .font(.system(size: 15,weight: .medium))
                                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "979797")))
                                Text(formatDateAndTime(from: order.dateAndTime).date)
                                    .font(.system(size: 15,weight: .bold))
                                Spacer()
                                Text("Time:")
                                    .font(.system(size: 15,weight: .medium))
                                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "979797")))
                                Text(formatDateAndTime(from: order.dateAndTime).time)
                                    .font(.system(size: 15,weight: .bold))
                            }
                            .padding()
                            Divider()
                            if customerAddress != nil {
                                HStack {
                                    
                                    Text(customerAddress!.address)
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 15,weight: .medium))
                                        .foregroundColor(.gray)
                                    Button(action: {
                                        print(customerAddress!.address)
                                    }, label: {
                                        Image("AddressNavFill")
                                            .frame(width: 48,height: 48)
                                    })
                                    
                                }
                                .padding()
                                Divider()
                            }
                            

                            OrderCardPicturesView(isLoading: $isLoading, orderPictures: $orderPictures)

                            
                            Divider()
                            EGTextField(text: $price)
                                .setTitleText("Enter your price for this Request:")
                                .setPlaceHolderText("Your Price")
                                .keyboardType(.decimalPad)
                                .padding()
                            Divider()
                            EGTextField(text: $description)
                                .setTitleText("Description")
                                .setPlaceHolderText("Description")
                                .setTextFieldHeight(50)
                                
                                .padding()
                            Spacer()
                                .frame(height: 20)
                        }
                        .background(content: {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white)
                                .shadow(color: .gray, radius: 5, x: 0, y: 2)
                            
                        })
                        .padding()
                        
                        
                        
                        if hasAdditionalInfo {
                            ZStack(content: {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                HStack {
                                    Image(systemName: "arrow.down")
                                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                    Text("Additional Info")
                                        .font(.system(size: 14,weight: .semibold))
                                }
                            })
                            .padding()
                            VStack {
                                Text("Description Description Description Description Description")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 15,weight: .medium))
                                //pictures loading
                            }
                            .padding()
                            .background(content: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.white)
                                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                
                            })
                        }
                        
                        
                    }
                    
                    
                }
                Button(action: {
                    DispatchQueue.main.async {
                        
                        guard let workerId = UserDefaults.standard.string(forKey: "WorkerId") else {
                            print("failed fetch WorkerId")
                            return
                        }
                        if let location = locationManager.location {
                            
//                            let offer = TenderOffer(id: nil, price: Double(self.price)!, description: self.description, workerLatitude: location.latitude, tenderOfferStatus: TenderOfferStatus.created, workerAltitude: location.latitude, isWorkerAccepted: true, isOrderAccepted: false, workerId: Int(workerId)!, orderId: order.id, verificationCode: nil)
                            let offer = TenderOffer(id: nil, price: Double(self.price)!, description: self.description, workerLatitude: 37.4220, tenderOfferStatus: TenderOfferStatus.created, workerAltitude: 122.0841, isWorkerAccepted: false, isOrderAccepted: true, workerId: Int(workerId)!, orderId: order.id, verificationCode: nil)
                            
                            self.offer = offer
                            alertMessage = "Are you sure about your offer?"
                            isWorkerSure = false
                            alertShowing = true
                        }else{
                            print("offer creating failed")
                        }
                    }
                }, label: {
                    HStack {
                        Text("Send an Offer")
                            .font(.system(size: 14,weight: .semibold))
                            .foregroundColor(.white)
                        
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 320,height: 50)
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#818CA1")))
                    }
                })
                .padding()
                .frame(alignment: .bottom)
                .alert(isPresented: $alertShowing, content: {
                    if isErrorAlerShowing {
                        return Alert(title: Text("Error"),message: Text(alertMessage))
                    }
                    if !isWorkerSure {
                        
                        return Alert(title: Text("Your Offer"),message: Text(alertMessage), primaryButton: .default(Text("Yes, Im sure"), action: {
                            isLoading = true
                            TenderOfferService.shared.saveNewTenderOffer(tenderOffer: self.offer!) { response in
                                isLoading = false
                                switch response {
                                case .success(let success):
                                    alertMessage = "Your offer has been successfully created,\nnow please wait for the customer's response."
                                    isOfferCreated = true
                                    isWorkerSure = true
                                case .failure(let failure):
                                    alertMessage = failure.localizedDescription
                                    isErrorAlerShowing = true
                                }
                                alertShowing.toggle()
                            }
                        }), secondaryButton: .cancel())
                    }
                    if isOfferCreated {
                        return Alert(title: Text("OFFER CREATED"),message: Text(alertMessage),dismissButton: .default(Text("Ok"), action: {
                            presentationMode.wrappedValue.dismiss()
                        }))
                            
                    }else{
                        return Alert(title: Text("OFFER STATUS"),message: Text(alertMessage))
                    }
                    
                })
            }
            if isLoading {
                MyProgressView()
            }
        }

//        .sheet(isPresented: $isImageShowing, onDismiss: {
//            print("Sheet dismissed, current image: \(String(describing: selectedImage))")
//            // Additional logic on dismiss if needed
//        }, content: {
//            if let image = selectedImage {
//                ImageViewer(image: .constant(Image(uiImage: image)), viewerShown: self.$isImageShowing)
//            } else {
//                Text("No image selected.")
//            }
//        })
        .onAppear {
            /*
             .onChange(of: imageViewModel.isLoading, { oldValue, newValue in
                 if newValue == false {
                     if let image = imageViewModel.image {
                         self.images.append(image)
                     }else{
                         print("first value")
                     }
                     
                 }else{
                     
                 }
             })
             .onAppear{
                 
                 for picture in orderPictures {
                     print("Order CardView: \(picture.pictureUrl)")
                     imageViewModel.loadImage(fileName: picture.pictureUrl)
                 }
                 
                 
             }
             */
            self.isLoading = true
            locationManager.requestLocation()
            orderPictureViewModel.fetchOrderPictures(orderId: order.id) { result in
                switch result {
                case .success(let orderPics):
                    print("orderPics.count: \(orderPics.count) orderId: \(order.id)")
                    for picture in orderPics {
                        imageViewModel.loadImageWithHandler(fileName: picture.pictureUrl) { uiImage in
                            print("loadImageWithHandler")
                            if let image = uiImage {
                                self.orderPictures.append(image)
                            }
                            
                        }
                    }
                case .failure(let error):
                    print("error")
                }
            }
            
            AddressService.shared.fetchCustomerAddressById(id: order.customerAddressId) { response in
                switch response {
                case .success(let address):
                    self.customerAddress = address
                case .failure(let failure):
                    self.alertMessage = failure.localizedDescription
                    self.alertShowing = true
                }
            }
            TenderOfferService.shared.checkIfOrderHasAdditionalInfo(orderId: "\(order.id)") { response in
                self.isLoading = false
                switch response {
                case .success(let success):
                    self.hasAdditionalInfo = success
                case .failure(let failure):
                    self.alertMessage = failure.localizedDescription
                    self.alertShowing = true
                }
            }
        }
        
    }
}

//#Preview {
//    OrderDetailsView()
//}
