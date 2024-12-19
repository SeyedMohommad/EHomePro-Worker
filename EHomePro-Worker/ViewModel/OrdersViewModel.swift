import Foundation
import Combine

class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    deinit {
        stopPolling()
    }
    
    func startPolling() {
        timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.fetchOrders()
        }
    }
    
    func stopPolling() {
        timer?.cancel()
    }
    
    func fetchOrders() {
        guard let workerId = UserDefaults.standard.string(forKey: "WorkerId") else {
            return
        }
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/worker/\(workerId)/orders/") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Messages Service")
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Order].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching orders: \(error)")
                }
            }, receiveValue: { [weak self] newOrders in
                self?.updateOrders(with: newOrders)
            })
            .store(in: &cancellables)
    }
    
    private func updateOrders(with newOrders: [Order]) {
        let newOrderIDs = Set(newOrders.map { $0.id })
        
        // Remove orders that are not in the newOrders list
        orders.removeAll { !newOrderIDs.contains($0.id) }
        
        // Add new orders
        let existingOrderIDs = Set(orders.map { $0.id })
        let addedOrders = newOrders.filter { !existingOrderIDs.contains($0.id) }
        
        if !addedOrders.isEmpty {
            orders.append(contentsOf: addedOrders)
        }
        
        // Sort the orders by date
        orders.sort(by: { dateFromArray($0.dateAndTime) > dateFromArray($1.dateAndTime) })
    }
    
    private func dateFromArray(_ dateArray: [Int]) -> Date {
        var components = DateComponents()
        if dateArray.count >= 5 {
            components.year = dateArray[0]
            components.month = dateArray[1]
            components.day = dateArray[2]
            components.hour = dateArray[3]
            components.minute = dateArray[4]
            return Calendar.current.date(from: components) ?? Date()
        }
        return Date()
    }
    
    func fetchOrderByID(_ orderId: Int, completion: @escaping (Order?) -> Void) {
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/order/\(orderId)/") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Orders Service")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Order.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionStatus in
                switch completionStatus {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching order by ID: \(error)")
                    completion(nil)
                }
            }, receiveValue: { order in
                completion(order)
            })
            .store(in: &cancellables)
    }
    
    func cancelOrder(orderId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/order/\(orderId)/cancel/") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Cancel Order Service")
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: String.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionStatus in
                switch completionStatus {
                case .finished:
                    break
                case .failure(let error):
                    print("Error canceling order: \(error)")
                    completion(.failure(error))
                }
            }, receiveValue: { response in
                if response == "CANCEL" {
                    completion(.success(response))
                } else {
                    completion(.failure(URLError(.unknown)))
                }
            })
            .store(in: &cancellables)
    }
    
    func updateOrderStatus(order: Order, newStatus: OrderStatusForRequest, completion: @escaping (Result<Order, Error>) -> Void) {
        
        
        var existingOrder = order
        // Step 2: Update the status of the fetched order
        existingOrder.status = newStatus.rawValue
        
        // Step 3: Send the updated order with a PATCH request
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/order/") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Update Order Status Service")
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(existingOrder)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Order.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionStatus in
                switch completionStatus {
                case .finished:
                    break
                case .failure(let error):
                    print("Error updating order status: \(error)")
                    completion(.failure(error))
                }
            }, receiveValue: { updatedOrder in
                completion(.success(updatedOrder))
            })
            .store(in: &self.cancellables)
    }
}


