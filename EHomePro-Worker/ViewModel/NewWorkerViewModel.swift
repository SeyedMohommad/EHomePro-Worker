//
//  NewWorkerViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import Foundation

class NewWorkerViewModel: ObservableObject {
    @Published var creationMessage: String = ""
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isWorkerCreated: Bool = false
    @Published var isErrorHappened: Bool = false
    @Published var email: String = ""
    @Published var socialSecurity: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    @Published var lastName: String = ""

    func createWorker(completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let url = URL(string: "https://gateway.intelligentehome.com/api/logicservice/user/newworker/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = NewWorkerRequest(email: self.email, password: self.password, name: self.name, lastName: self.lastName)
        request.httpBody = try? JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.isErrorHappened = true
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false, self.errorMessage)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Unexpected response from server"
                    completion(false, self.errorMessage)
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    self.creationMessage = "Worker created successfully."
                    self.isWorkerCreated = true
                    completion(true, nil)
                } else if httpResponse.statusCode != 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                            // Attempt to decode the inner JSON from the message field
                            if let innerMessageData = errorResponse.message.data(using: .utf8),
                               let innerMessage = try? decoder.decode(InnerMessage.self, from: innerMessageData) {
                                self.errorMessage = innerMessage.errorMessage
                            } else {
                                self.errorMessage = "Error parsing inner message"
                            }
                            completion(false, self.errorMessage)
                        } else {
                            self.errorMessage = "Unknown error occurred"
                            completion(false, self.errorMessage)
                        }
                    } else {
                        self.errorMessage = "Unknown error occurred"
                        completion(false, self.errorMessage)
                    }
                }
            }
        }.resume()
    }

}
