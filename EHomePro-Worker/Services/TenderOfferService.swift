//
//  TenderOfferService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/15/24.
//

import Foundation

class TenderOfferService {
    
    // MARK: - Singleton Instance
    static let shared = TenderOfferService()
    
    // MARK: - Private Init to Prevent Instantiation
    private init() {}
    
    // MARK: - Fetch Tender Offers
    func fetchTenderOffersInAction(_ id:Int,completion: @escaping (Result<[TenderOffer], Error>) -> Void) {
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/tenderoffer/status/inaction/\(id)/") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let tenderOffers = try JSONDecoder().decode([TenderOffer].self, from: data)
                completion(.success(tenderOffers))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Check If Order Has Additional Info
    func checkIfOrderHasAdditionalInfo(orderId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/order/\(orderId)/hasadditionalinfo/") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let hasAdditionalInfo = try JSONDecoder().decode(Bool.self, from: data)
                completion(.success(hasAdditionalInfo))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Save New Tender Offer
    func saveNewTenderOffer(tenderOffer: TenderOffer, completion: @escaping (Result<TenderOffer, Error>) -> Void) {
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/tenderoffer") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let jsonData = try JSONEncoder().encode(tenderOffer)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let savedTenderOffer = try JSONDecoder().decode(TenderOffer.self, from: data)
                completion(.success(savedTenderOffer))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }
        
        task.resume()
    }

    // MARK: - Fetch Tender Offers by Status
    func fetchTenderOffersByStatus(status: TenderOfferStatus, id: Int, completion: @escaping (Result<[TenderOffer], Error>) -> Void) {
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/tenderoffer/status/\(status.rawValue)/\(id)/") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let tenderOffers = try JSONDecoder().decode([TenderOffer].self, from: data)
                completion(.success(tenderOffers))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }
        
        task.resume()
    }
    
    func getTenderOfferById(id: Int, completion: @escaping (Result<TenderOffer, Error>) -> Void) {
            guard let url = URL(string: "\(getRestUrl())/api/logicservice/tenderoffer/\(id)/") else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            guard let token = UserDefaults.standard.string(forKey: "access_token") else {
                print("No access token found")
                return
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let tenderOffer = try JSONDecoder().decode(TenderOffer.self, from: data)
                    completion(.success(tenderOffer))
                } catch let decodingError {
                    completion(.failure(decodingError))
                }
            }
            
            task.resume()
        }

    func verifyTenderOffer(id: Int, verificationCode: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            guard let url = URL(string: "\(getRestUrl())/api/logicservice/tenderoffer/\(id)/verify/\(verificationCode)") else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            guard let token = UserDefaults.standard.string(forKey: "access_token") else {
                print("No access token found")
                return
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let isVerified = try JSONDecoder().decode(Bool.self, from: data)
                    completion(.success(isVerified))
                } catch let decodingError {
                    completion(.failure(decodingError))
                }
            }
            
            task.resume()
        }

    
    
    // MARK: - Update Tender Offer
    func updateTenderOfferStatus(_ tenderOffer: TenderOffer,status: TenderOfferStatus ,completion: @escaping (Result<TenderOffer, Error>) -> Void) {
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/tenderoffer") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Create a copy of the tenderOffer with updated status
        let updatedTenderOffer = TenderOffer(
            id: tenderOffer.id,
            price: tenderOffer.price,
            description: tenderOffer.description,
            workerLatitude: tenderOffer.workerLatitude,
            tenderOfferStatus: status, // Updated status
            workerAltitude: tenderOffer.workerAltitude,
            isWorkerAccepted: tenderOffer.isWorkerAccepted,
            isOrderAccepted: tenderOffer.isOrderAccepted,
            workerId: tenderOffer.workerId,
            orderId: tenderOffer.orderId,
            verificationCode: tenderOffer.verificationCode
        )

        
        do {
            let jsonData = try JSONEncoder().encode(updatedTenderOffer)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let updatedTenderOfferResponse = try JSONDecoder().decode(TenderOffer.self, from: data)
                completion(.success(updatedTenderOfferResponse))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }
        
        task.resume()
    }

    
    func fetchTenderOffersByStatuses(statuses: [TenderOfferStatus], id: Int, completion: @escaping (Result<[TenderOffer], Error>) -> Void) {
        var allTenderOffers: [TenderOffer] = []
        var errors: [Error] = []
        let group = DispatchGroup()
        
        for status in statuses {
            group.enter()
            fetchTenderOffersByStatus(status: status, id: id) { result in
                switch result {
                case .success(let tenderOffers):
                    allTenderOffers.append(contentsOf: tenderOffers)
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if !errors.isEmpty {
                // Return the first error encountered, or customize this behavior
                completion(.failure(errors.first!))
            } else {
                completion(.success(allTenderOffers))
            }
        }
    }

    
}

