//
//  AcceptedTenderOfferViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 10/26/24.
//

import Foundation
import Combine

class AcceptedTenderOfferViewModel: ObservableObject {
    @Published var acceptedTenderOffers: [AcceptedTenderOffer]?
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    func fetchTenderOffer(for workerId: Int) {
        print("fetchTenderOffer")
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/acceptedtenderoffer/worker/\(workerId)/") else {
            self.errorMessage = "Invalid URL"
            return
        }
        var request = URLRequest(url: url)
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [AcceptedTenderOffer].self, decoder: JSONDecoder.customDateDecoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    
                    self.errorMessage = "Failed to fetch tender offer: \(error.localizedDescription)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] offer in
                self?.acceptedTenderOffers = offer
                self?.errorMessage = nil
            })
            .store(in: &cancellables)
    }
    
    func startPolling(for workerId: Int, interval: TimeInterval = 15) {
        timer?.invalidate() // Stop previous timer if exists
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.fetchTenderOffer(for: workerId)
        }
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopPolling()
    }
}

extension JSONDecoder {
    static var customDateDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateArray = try container.decode([Int].self)
            var components = DateComponents()
            components.year = dateArray[0]
            components.month = dateArray[1]
            components.day = dateArray[2]
            components.hour = dateArray[3]
            components.minute = dateArray[4]
            components.second = dateArray[5]
            let calendar = Calendar.current
            return calendar.date(from: components)!
        }
        return decoder
    }
}
