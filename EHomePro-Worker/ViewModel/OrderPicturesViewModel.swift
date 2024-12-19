//
//  OrderPicturesViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/12/24.
//

import Foundation
import Combine

// ViewModel for managing and displaying order pictures
class OrderPicturesViewModel: ObservableObject {
    @Published var orderPictures: [OrderPicture] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    // Function to fetch order pictures from the server with a completion handler
    func fetchOrderPictures(orderId: Int, completion: @escaping (Result<[OrderPicture], Error>) -> Void) {
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/orderpicture/getAll/\(orderId)/") else {
            self.errorMessage = "Invalid URL"
            completion(.failure(URLError(.badURL)))
            return
        }
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return 
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        self.isLoading = true
        
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: [OrderPicture].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionResult in
                self.isLoading = false
                switch completionResult {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }, receiveValue: { orderPictures in
                self.orderPictures = orderPictures
                completion(.success(orderPictures))
            })
            .store(in: &self.cancellables)
        
    
    }
}
