//
//  ResetPasswordViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import Foundation

class ResetPasswordViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isRequestFinished: Bool = false
    func resetPassword(email: String) {
        guard email != "" else {
            self.isRequestFinished = true
            
            errorMessage = "Please Enter Your Email"
            return
        }
        self.isLoading = true
        guard let url = URL(string: "https://gateway.intelligentehome.com/api/logicservice/user/resetPassword/\(email.urlEncoded())/") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("*/*", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.isRequestFinished = true
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                    do {
                        let loginError = try JSONDecoder().decode(RSLoginError.self, from: data!)
                        self.errorMessage = loginError.errorMessage
                    } catch {
                        self.errorMessage = "Failed to decode error message"
                    }
                } else if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    // Successful reset (204 No Content expected)
                    self.errorMessage = nil
                }
            }
        }.resume()
    }
}

extension String {
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
