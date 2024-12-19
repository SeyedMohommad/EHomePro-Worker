//
//  AcceptedTenderOfferView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 11/1/24.
//

import SwiftUI
import MapKit
import HalfASheet
import CoreLocation
import CustomTextField
import Combine

struct AcceptedTenderOfferView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), // Default to 0,0; will update with user location
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @StateObject private var locationManager = AcceptedTenderOfferLocationManager()
    @StateObject private var ordersViewModel = OrdersViewModel()
    @StateObject private var additionalInfoViewModel = AdditionalInfoViewModel()
    
    
    @State private var locations:[CustomerLocation]? // Add more locations if needed
    
    @State private var isAlertShowing = false
    @State private var alertMessage = ""
    
    @State private var isEnterTheCodeButtonTouched = false
    @State private var digits = Array(repeating: "", count: 7)
    @FocusState private var focusedField: Int?
    
    let offer:(offer: TenderOffer, customer:Customer, order:Order)?
    
    @State private var isLoading = false
    
    @State private var hasWorkerArrived = false
    @State private var isRejected = false
    
    @State private var addNewAdditionInfo = false
    @State private var isAdditionalInfoAdded = false
    @State private var isJobAccepted = false
    @State private var additionalInfoDescription:String = ""
    @State private var additionalInfoPrice:String = ""
    @State private var additionalInfoImages: [Image] = [] // For display
    @State private var additionalInfoImageDatas: [Data] = [] // For upload
    
    @State private var workerLocation: StartedLocationRequest?
    
    @State private var pollingTimer: Timer?
    
    var body: some View {
        ZStack {
            if let locations = locations {
                // Map View
                Map(coordinateRegion: $locationManager.region, annotationItems: locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        Image("location") // Use the custom image named "location"
                            .resizable()
                            .frame(width: 30, height: 30)
                            .shadow(radius: 5)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }else{
                Map()
                    .blur(radius: 1)
            }
            
            
            // Overlay Card
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        
                        
                        HStack {
                            if let offer = offer {
                                if let profilePicture = offer.customer.profilePicture {
                                    UserSmallPictureView(imageName: nil, uiImage: ImageService.shared.loadProfileImage(fileName: profilePicture))
                                }else{
                                    UserSmallPictureView(imageName: nil, uiImage: nil)
                                }
                                
                            }else{
                                UserSmallPictureView(imageName: nil, uiImage: nil)
                            }
                            
                            
                            if let offer = offer {
                                Text(offer.customer.name + " " + offer.customer.lastName)
                                    .font(.headline)
                                    .padding(.leading, 5)
                            }
                            
                            Spacer()
                            Button(action: {
                                //                                    // Action for the button
                                //                                    if tenderOffer.offer.tenderOfferStatus == .accepted ||  tenderOffer.offer.tenderOfferStatus == .acceptedSecondTry || tenderOffer.offer.tenderOfferStatus == .inAction {
                                //
                                //                                        UIApplication.shared.open(URL(string: "tel://\(tenderOffer.customer.phoneNumber)")!)
                                //                                    }else{
                                //
                                //                                        alertMessage = "You cannot contact the customer before accepting your offer!"
                                //                                        isAlertShowing = true
                                //                                    }
                                
                                
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
                                //                                    if tenderOffer.offer.tenderOfferStatus == .accepted ||  tenderOffer.offer.tenderOfferStatus == .acceptedSecondTry || tenderOffer.offer.tenderOfferStatus == .inAction {
                                //                                        // making room and start messaging
                                //                                    }else{
                                //                                        alertMessage = "You cannot contact the customer before accepting your offer!"
                                //                                        isAlertShowing = true
                                //                                    }
                                
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
                        if let offer = offer {
                            Text("$\(formatPrice(offer.offer.price))")
                                .font(.title2)
                                .bold()
                                .padding(.top, 5)
                        }
                        
                        Spacer()
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                Text("Direction")
                            }
                            .frame(width: 120)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    Divider()
                    if let offer = offer {
                        
                        HStack {
                            Image(systemName: "calendar")
                            let dateAndTime = formatDateAndTime(from: offer.order.dateAndTime)
                            Text(dateAndTime.date)
                            Spacer()
                            Image(systemName: "clock")
                            Text( dateAndTime.time)
                        }
                        .padding(.top, 2)
                    }
                    Divider()
                    if !hasWorkerArrived {
                        Button(action: {
                            isEnterTheCodeButtonTouched = true
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: 320,height: 50)
                                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#818CA1")))
                                HStack {
                                    Spacer()
                                    Image(systemName: "key.card")
                                        .foregroundColor(.white)
                                    Text("Enter the code")
                                        .font(.system(size: 14,weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                            
                            
                            //                        .padding()
                        }
                    }else{
                        if isJobAccepted {
                            Button {
                                if let offer = offer {
                                    TenderOfferService.shared.updateTenderOfferStatus(offer.offer, status: .done) { response in
                                        switch response {
                                        case .success(_):
                                            ordersViewModel.updateOrderStatus(order: offer.order, newStatus: .done) { response in
                                                switch response {
                                                case .success(_):
                                                    dismiss()
                                                    alertMessage = "Thank you, have a nice day!"
                                                    isAlertShowing = true
                                                case .failure(let failure):
                                                    dismiss()
                                                    alertMessage = failure.localizedDescription
                                                    isAlertShowing = true
                                                }
                                            }
                                            
                                        case .failure(let failure):
                                            alertMessage = failure.localizedDescription
                                            isAlertShowing = true
                                        }
                                    }
                                }
                                
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .frame(width: 320,height: 50)
                                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#818CA1")))
                                    HStack {
                                        
                                        Text("Finish Work")
                                            .font(.system(size: 14,weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }else{
                            HStack(alignment: .center,spacing: 20) {
                                Button {
                                    if let offer = offer {
                                        TenderOfferService.shared.updateTenderOfferStatus(offer.offer, status: .inAction) { response in
                                            switch response {
                                            case .success(_):
                                                alertMessage = "offer accepted,\nNow you can start your job."
                                                isAlertShowing = true
                                                isJobAccepted = true
                                            case .failure(let failure):
                                                alertMessage = "Tender Offer accepting failed,\ntrye again a few moments later."
                                                isAlertShowing = true
                                            }
                                        }
                                    }
                                    
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .frame(width: 140,height: 50)
                                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#818CA1")))
                                        Text("Accept")
                                            .font(.system(size: 14,weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                
                                Button {
                                    isRejected = true
                                    //                                isAlertShowing = true
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .frame(width: 140,height: 50)
                                            .foregroundColor(.red)
                                        Text("Reject")
                                            .font(.system(size: 14,weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    
                                }
                                .alert("Reject Task", isPresented: $isRejected) {
                                    
                                    Button("Add additional information") {
                                        addNewAdditionInfo = true
                                        
                                    }
                                    
                                    Button("Reject anyway", role: .destructive) {
                                        isLoading = true
                                        if let offer = offer {
                                            ordersViewModel.cancelOrder(orderId: offer.order.id) { response in
                                                switch response {
                                                case .success(let success):
                                                    alertMessage = "This order has been cancelled successfully."
                                                    isAlertShowing = true
                                                case .failure(let error):
                                                    alertMessage = error.localizedDescription
                                                    isAlertShowing = true
                                                }
                                            }
                                        }
                                        
                                    }
                                    Button("Cancel", role: .cancel) {
                                        // do nothing...
                                    }
                                } message: {
                                    Text("Do you want to reject the task entirely or provide additional information?")
                                }
                            }
                            .padding()
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                .shadow(radius: 10)
                .padding()
            }
            
            if isLoading {
                MyProgressView()
            }
            if isEnterTheCodeButtonTouched {
                HalfASheet(isPresented: $isEnterTheCodeButtonTouched, title: "Verfication Code") {
                    
                    VStack(spacing: 10) {
                        Text("Ask the code from customer and enter it here.")
                            .font(.caption)
                        HStack(spacing: 10) {
                            ForEach(0..<digits.count, id: \.self) { index in
                                TextField("", text: $digits[index])
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 40, height: 40)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(focusedField == index ? Color.blue : Color.gray, lineWidth: 2))
                                    .font(.system(size: 20))
                                    .focused($focusedField, equals: index)
                                    .onChange(of: digits[index]) { newValue in
                                        // Limit to one digit per field
                                        if newValue.count > 1 {
                                            digits[index] = String(newValue.prefix(1))
                                        }
                                        // Move focus to the next field if current one has a digit
                                        if !newValue.isEmpty {
                                            if index < digits.count - 1 {
                                                focusedField = index + 1
                                            } else {
                                                focusedField = nil // dismiss keyboard if it's the last field
                                                isLoading = true
                                                var verifyCode: String = ""
                                                for digit in digits {
                                                    verifyCode += "\(digit)"
                                                }
                                                if let offer = offer {
                                                    TenderOfferService.shared.verifyTenderOffer(id: offer.offer.id ?? 0, verificationCode: verifyCode) { response in
                                                        isLoading = false
                                                        switch response {
                                                        case .success(let isCorrect):
                                                            if isCorrect {
                                                                DispatchQueue.main.async {
                                                                    isEnterTheCodeButtonTouched = false
                                                                    alertMessage = "Your code is verfied successfully"
                                                                    hasWorkerArrived = true
                                                                    UserDefaults.standard.set(offer.offer.id, forKey: "\(offer.offer.id)")
                                                                    UserDefaults.standard.synchronize()
                                                                }
                                                                
                                                            }else{
                                                                digits.removeAll()
                                                                alertMessage = "Your code is not correct"
                                                            }
                                                            
                                                        case .failure(let error):
                                                            alertMessage = error.localizedDescription
                                                            
                                                        }
                                                        isAlertShowing = true
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                        .onAppear {
                            focusedField = 0 // Start focus on the first field
                        }
                        
                    }
                }
                
                .height(.proportional(0.5))
                .backgroundColor(.white)
                
                
            }
            
            HalfASheet(isPresented: $addNewAdditionInfo) {
                VStack(alignment:.center) {
                    HStack {
                        Spacer()
                        Text("Add new addition information")
                        Spacer()
                    }
                    
                    
                    
                    EGTextField(text: $additionalInfoPrice)
                        .setTextFieldHeight(30)
                        .setTitleText("Price")
                    
                    
                    EGTextField(text: $additionalInfoDescription)
                        .setTitleText("Description")
                        .setTextFieldHeight(80)
                    
                    
                    
                    DocumentUploaderView(images: $additionalInfoImages, imageDatas: $additionalInfoImageDatas)
                    Button {
                        if let workerId = UserDefaults.standard.string(forKey: "WorkerId") {
                            if let offer = offer {
                                additionalInfoViewModel.createAdditionalInfo(description: additionalInfoDescription, workerId: Int(workerId)!, orderId: offer.order.id) { additionalInfo in
                                    
                                    if let additionalInfo = additionalInfo {
                                        additionalInfoViewModel.uploadPicturesSequentially(id: additionalInfo.id, images: additionalInfoImageDatas) { success in
                                            if success {
                                                isAdditionalInfoAdded = true
                                                alertMessage = "Additional information added successfully."
                                                isAlertShowing = true
                                                dismiss()
                                            } else {
                                                isAdditionalInfoAdded = true
                                                alertMessage = "Additional information added, but image upload failed.\n \(additionalInfoViewModel.errorMessage)"
                                                isAlertShowing = true
                                                dismiss()
                                            }
                                        }
                                    } else {
                                        isAdditionalInfoAdded = true
                                        alertMessage = "We could not process your request. \nPlease try again later."
                                        isAlertShowing = true
                                    }
                                }
                            }
                        }
                    } label: {
                        WideButtonStyleView(buttonText: "Send", buttonLogo: "")
                    }
                    
                    
                    
                }
            }
            .backgroundColor(.white)
            .height(.proportional(0.55))
            
        }
        
        
        
        .onAppear {
            
            if let offer = offer {
                fetchCustomerLocation(for: offer)
                if offer.offer.tenderOfferStatus == .accepted {
//                    startPollingLocation()
                }
                if let _ = UserDefaults.standard.object(forKey: "\(offer.offer.id)") {
                    hasWorkerArrived = true
                }
                if offer.offer.tenderOfferStatus == .inAction {
                    isJobAccepted = true
                }
            } else {
                alertMessage = "Error loading the offer"
                isAlertShowing = true
            }
        }
        .alert(isPresented: $isAlertShowing) {
            if isRejected {
                Alert(
                    title: Text("Reject"),
                    message: Text("Do you want to reject the task entirely or provide additional information?"),
                    primaryButton: .default(Text("Add additional information"), action: {
                        // Add additional information
                        print("Add additional information")
                    }),
                    secondaryButton: .destructive(Text("Reject Anyway"), action: {
                        // Reject
                        print("Reject Anyway")
                    })
                )
                // Add Cancel button to dismiss the alert
                
                
                
            }else if isAdditionalInfoAdded {
                
                Alert(title: Text("Additional Infomation"),message: Text(alertMessage))
            }else{
                Alert(title: Text("Alert"),message: Text(alertMessage))
            }
            
        }
    }
    private func fetchCustomerLocation(for offer: (offer: TenderOffer, customer: Customer, order: Order)) {
        isLoading = true
        AddressService.shared.fetchCustomerAddressById(id: offer.order.customerAddressId) { response in
            isLoading = false
            switch response {
            case .success(let address):
                let customerLocation = CustomerLocation(coordinate: CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude))
                self.locations = [customerLocation]
            case .failure(let error):
                alertMessage = error.localizedDescription
                isAlertShowing = true
            }
        }
    }
    
    
}

//#Preview {
//    AcceptedTenderOfferView(offer: nil)
//}


struct CustomerLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    
    static let exampleLocation = CustomerLocation(coordinate: CLLocationCoordinate2D(latitude: 40.7648, longitude: -73.9808)) // Sample location
}


extension AcceptedTenderOfferView {
    class Coordinator: NSObject, CLLocationManagerDelegate {
        var parent: AcceptedTenderOfferView
        
        init(_ parent: AcceptedTenderOfferView) {
            self.parent = parent
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                parent.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                manager.stopUpdatingLocation() // Stop updating to save battery
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            parent.alertMessage = "Failed to fetch user location: \(error.localizedDescription)"
            parent.isAlertShowing = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    private let onUpdate: (CLLocation) -> Void
    
    init(onUpdate: @escaping (CLLocation) -> Void) {
        self.onUpdate = onUpdate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            onUpdate(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}

class AcceptedTenderOfferLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            currentLocation = location.coordinate
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    
    private func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    private func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}
