//
//  RoomViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/5/24.
//

import SwiftUI
import Combine

class RoomViewModel: ObservableObject {
    @Published var rooms: [RoomWithCustomer] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    func fetchRooms(for workerId: Int) {
        isLoading = true
        
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/room/list/worker/\(workerId)/") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "Missing or invalid access token"
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode == 401 {
                    AuthenticationService.shared.refreshToken { success in
                        if success {
                            self.fetchRooms(for: workerId)
                        }
                    }
                    throw URLError(.userAuthenticationRequired)
                }
                guard httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .receive(on: DispatchQueue.main)
            .decode(type: [Room].self, decoder: JSONDecoder())
            .mapError { error in
                error
            }
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error fetching rooms: \(error.localizedDescription)"
                        print("Error: \(error)")
                        self?.isLoading = false
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] rooms in
                self?.updateRooms(rooms)
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    private func updateRooms(_ rooms: [Room]) {
        var updatedRooms: [RoomWithCustomer] = []
        
        let group = DispatchGroup()
        
        for room in rooms {
            group.enter()
            CustomerService.shared.getCustomer(by: room.worker_id) { response in
                switch response {
                case .success(let customer):
                    if let profilePicture = customer.profilePicture {
                        ImageService.shared.loadImage(fileName: profilePicture)
                    }
                    let roomWithCustomer = RoomWithCustomer(id: room.id, worker_id: room.worker_id, customer: customer, created_at: room.created_at, has_unread_messages: room.has_unread_messages)
                    updatedRooms.append(roomWithCustomer)
                case .failure(let error):
                    print(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                if self.rooms != updatedRooms {
                    withAnimation {
                        self.rooms = updatedRooms
                    }
                }
            }
        }
    }
}

