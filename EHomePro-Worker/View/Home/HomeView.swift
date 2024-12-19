//
//  HomeView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/3/24.
//

import SwiftUI

struct HomeView: View {
    @State private var status = false
    
    @State private var hasProfile = true
    
    @State private var currentJob:String? = nil
    
    @State private var orders:[Order] = []
    
    @State private var currentTenderOffers:[(offer: TenderOffer, customer:Customer, order:Order)] = []
    
    
    
    @State private var isLoading = true
    @State private var isAlertShowing = false
    @State private var alertMessage = ""
    
    @StateObject private var ordersViewModel = OrdersViewModel()
    @StateObject private var acceptedTenderOfferViewModel = AcceptedTenderOfferViewModel()
    
    @State private var isAcceptedTenderOfferSelected = false
    @State private var selctedAcceptedOffer: (offer: TenderOffer, customer:Customer, order:Order)?
    var body: some View {
        
            ZStack {
                ScrollView {
                    VStack {
                        if hasProfile {
                            if !currentTenderOffers.isEmpty {
                                //                    if currentTenderOffers.isEmpty {
                                ScrollView(.horizontal) {
                                    HStack {
                                        
                                        ForEach(currentTenderOffers, id:\.0.id) { tenderOffer in
                                            CurrentJobView(tenderOffer: tenderOffer)
                                                .padding(.leading)
                                                .padding(.trailing)
                                                .onTapGesture {
                                                    if tenderOffer.offer.isOrderAccepted != nil &&  tenderOffer.offer.isOrderAccepted == true{
                                                        DispatchQueue.main.async {
                                                            self.selctedAcceptedOffer = tenderOffer
                                                            self.isAcceptedTenderOfferSelected = true
                                                        }
                                                        
                                                    }else{
                                                        alertMessage = "Your offer has not been approved yet."
                                                        isAlertShowing = true
                                                    }
                                                    
                                                }
                                        }
                                    }
                                    .padding()
                                    
                                }
                                
                                
                            }
                            if status {
                                ZStack(content: {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(.white)
                                        .frame(height: 50)
                                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                    HStack {
                                        Image(systemName: "arrow.down")
                                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "#979797")))
                                        Text("Suggested Activities")
                                            .font(.system(size: 14,weight: .semibold))
                                    }
                                })
                                .padding()
                                Spacer()
                                
                                
                                
                                ScrollView {
                                    
                                    VStack {
                                        
                                        ForEach(ordersViewModel.orders) { order in
                                            OrderCardView(order: order, isLoading: $isLoading)
                                                .padding()
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                
                            }else{
                                Spacer()
                                RestingModeView()
                                Spacer()
                            }
                            
                            
                        }else{
                            FillInformationView()
                        }
                    }
                    .onAppear {
                        print("onAppear")
                        loadData()
                        fetchAccptedTenderOffers()
                    }
                    
                    NavigationLink(destination: AcceptedTenderOfferView(offer: selctedAcceptedOffer) , isActive: $isAcceptedTenderOfferSelected) {
                        EmptyView()
                    }
                }
                VStack {
                    Spacer()
                    StatusToggleView(status: $status)
                        .padding(.bottom)
                        .shadow(radius: 2)
                    
                    
                    
                        .onChange(of: ordersViewModel.orders.isEmpty, { oldValue, newValue in
                            if !newValue {
                                isLoading = false
                            }
                        })
                }
                .alert(isPresented: $isAlertShowing, content: {
                    Alert(title: Text("Message"),message: Text(alertMessage))
                })
                
                
                .onChange(of: acceptedTenderOfferViewModel.acceptedTenderOffers) { newValue in
                    DispatchQueue.main.async {
                        self.isLoading = true
                        if let newAcceptedOffers = newValue {
                            for acceptedOffer in newAcceptedOffers {
                                TenderOfferService.shared.getTenderOfferById(id: acceptedOffer.tenderOfferId) { response in
                                    
                                    switch response {
                                    case .success(let tenderOffer):
                                        ordersViewModel.fetchOrderByID(acceptedOffer.orderId) { order in
                                            if let order = order {
                                                CustomerService.shared.getCustomer(by: order.customerId) { response in
                                                    switch response {
                                                    case .success(let customer):
                                                        let currentToffer = (offer: tenderOffer, customer: customer, order: order)
                                                        currentTenderOffers.append(currentToffer)
                                                        self.isLoading = false
                                                    case .failure(let failure):
                                                        print(failure.localizedDescription)
                                                    }
                                                }
                                            }
                                        }
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
                
                
            }
        if isLoading {
            MyProgressView()
            
        }
        
    }
    
    
    private func fetchAccptedTenderOffers() {
        let workerId = UserDefaults.standard.string(forKey: "WorkerId")
        if let workerID = workerId {
            print("workerId: \(workerId!)")
            acceptedTenderOfferViewModel.fetchTenderOffer(for: Int(workerID)!)
            acceptedTenderOfferViewModel.startPolling(for: Int(workerID)!)
        
        }else{
            
            WorkerService.shared.fetchWorkerDatabyEmail { _, _ in
                if isKeyPresentInUserDefaults(key: "WorkerId") {
                    let updatedWorkerId = UserDefaults.standard.string(forKey: "WorkerId")
                    
                    acceptedTenderOfferViewModel.fetchTenderOffer(for: Int(updatedWorkerId!)!)
                    acceptedTenderOfferViewModel.startPolling(for: Int(updatedWorkerId!)!)

                }else{
                    alertMessage = "something happend to fetching your profile"
                    isAlertShowing = true
                }
            }
            
        }
        
        
    }
    
    private func loadData() {
        DispatchQueue.main.async {
            self.isLoading = true
            if isKeyPresentInUserDefaults(key: "hasProfile") != false {
            
                alertMessage = "Please fill the information to continue"
                isAlertShowing = true
            }else {
                let hasWorkerFilledInfo = UserDefaults.standard.bool(forKey: "hasProfile")
                
                if hasWorkerFilledInfo {
                    self.hasProfile = false
                }else{
                    
                    WorkerService.shared.fetchWorkerDatabyEmail { worker, error in
                        if worker != nil {
                            TenderOfferService.shared.fetchTenderOffersByStatuses(statuses: [.accepted,.created], id: worker!.id) { response in
                                switch response {
                                    
                                case .success(let tenderOffers):
                                    //                                    if !tenderOffers.isEmpty {
                                    //                                        self.currentTenderOffers = tenderOffers
                                    self.currentTenderOffers.removeAll()
                                    for currentTenderOffer in tenderOffers {
                                        ordersViewModel.fetchOrderByID(currentTenderOffer.orderId) { order in
                                            if order != nil {
                                                CustomerService.shared.getCustomer(by: order!.customerId) { response in
                                                    switch response {
                                                    case .success(let customer):
                                                        let cofferCustomer:(offer: TenderOffer, customer:Customer, order:Order) = (currentTenderOffer,customer , order!)
                                                        self.currentTenderOffers.append(cofferCustomer)
                                                    case .failure(let failure):
                                                        print("failed by this error Home View getCustomer:\(failure.localizedDescription) ")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    //                                    }
                                case .failure(let failure):
                                    print("failed \(failure.localizedDescription)")
                                }
                            }
                            
                            TenderOfferService.shared.fetchTenderOffersByStatus(status: .inAction, id: worker!.id) { response in
                                switch response {
                                case .success(let tenderOffers):
                                    //                                    if !tenderOffers.isEmpty {
                                    //                                    self.currentTenderOffers += tenderOffers
                                    for currentTenderOffer in tenderOffers {
                                        ordersViewModel.fetchOrderByID(currentTenderOffer.orderId) { order in
                                            if order != nil {
                                                CustomerService.shared.getCustomer(by: order!.customerId) { response in
                                                    switch response {
                                                    case .success(let customer):
                                                        let cofferCustomer:(offer: TenderOffer, customer:Customer, order:Order) = (currentTenderOffer,customer , order!)
                                                        self.currentTenderOffers.append(cofferCustomer)
                                                    case .failure(let failure):
                                                        print("failed by this error Home View getCustomer:\(failure.localizedDescription) ")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    //                                    }
                                case .failure(let failure):
                                    print("failed \(failure.localizedDescription)")
                                }
                            }
                            
                            
                            WorkerService.shared.checkWorkerProfileInformation(id: worker!.id) { fields,error  in
                                self.isLoading = false
                                if error != nil {
                                    if fields.isEmpty {
                                        self.hasProfile = true
                                        if worker!.workerStatus == "ONLINE" {
                                            self.status = true
                                            ordersViewModel.fetchOrders()
                                            ordersViewModel.startPolling()
                                        }
                                    }else{
                                        // handle fields
                                    }
                                }else{
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}

//#Preview {
//    HomeView()
//}
