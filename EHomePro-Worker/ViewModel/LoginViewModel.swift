//
//  LoginViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import SwiftUI
import Foundation
import Security
import LocalAuthentication


class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var isErrorHappened: Bool = false
    @Published var errorMessage: String = ""
    
    func login() {
        
        
            self.isLoading = true
            
            let domain = getRestUrl()
            let url = URL(string: "\(domain)/api/logicservice/user/login/")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: String] = [
                "username": self.email,
                "password": self.password
            ]
            request.httpBody = try? JSONEncoder().encode(body)
            DispatchQueue.main.async {
                
                
                URLSession.shared.dataTask(with: request) { data, response, error in
                    
                    DispatchQueue.main.async {
                        
                            self.isLoading = false
                        
                    }
                    guard let data = data, error == nil else {
                        DispatchQueue.main.async {
                            self.errorMessage = error?.localizedDescription ?? "Unknown error occurred"
                        }
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        
                        if let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                            DispatchQueue.main.async {
                                self.saveLoginDetails(loginResponse)
                                self.isLoggedIn = true
                                self.saveCredentialsToKeychain(email: self.email, password: self.password)
//                                CustomerService.shared.fetchCustomerDatabyEmail { customer, error in
//                                    if let customer = customer {
//                                        DispatchQueue.main.async {
//                                            UserDefaults.standard.setValue(customer.id, forKey: "CustomerId")
//                                        }
//                                        
//                                    } else {
//                                        self.errorMessage = error ?? "Failed to fetch customer data"
//                                    }
//                                }
                            }
                        }
                    } else {
                        if let loginError = try? JSONDecoder().decode(LoginError.self, from: data) {
                            DispatchQueue.main.async {
                                self.isErrorHappened = true
                                self.errorMessage = self.parseErrorMessage(loginError.message)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.errorMessage = "Failed to login for an unknown reason."
                            }
                        }
                    }
                }.resume()
            }
        
    }
    
    private func saveLoginDetails(_ response: LoginResponse) {
        UserDefaults.standard.set(response.access_token, forKey: "access_token")
        UserDefaults.standard.set(response.refresh_token, forKey: "refresh_token")
        UserDefaults.standard.set(self.email, forKey: "email")
        UserDefaults.standard.synchronize()
    }
    
    private func parseErrorMessage(_ message: String) -> String {
        if let data = message.data(using: .utf8),
           let json = try? JSONDecoder().decode([String: String].self, from: data),
           let errorDescription = json["error_description"] {
            return errorDescription
        }
        return "An error occurred"
    }
    
    func retrieveCredentialsFromKeychain() -> (email: String, password: String)? {
        let emailKey = "userEmail"
        let passwordKey = "userPassword"
        
        // Retrieve email from the keychain
        let queryEmail: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: emailKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var emailData: CFTypeRef?
        let statusEmail = SecItemCopyMatching(queryEmail as CFDictionary, &emailData)
        guard statusEmail == errSecSuccess,
              let email = emailData as? Data,
              let extractedEmail = String(data: email, encoding: .utf8) else {
            print("Failed to retrieve email from keychain")
            return nil
        }
        
        // Retrieve password from the keychain
        let queryPassword: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: passwordKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var passwordData: CFTypeRef?
        let statusPassword = SecItemCopyMatching(queryPassword as CFDictionary, &passwordData)
        guard statusPassword == errSecSuccess,
              let password = passwordData as? Data,
              let extractedPassword = String(data: password, encoding: .utf8) else {
            print("Failed to retrieve password from keychain")
            return nil
        }
        
        return (email: extractedEmail, password: extractedPassword)
    }
    
    func saveCredentialsToKeychain(email: String, password: String) {
        let emailKey = "userEmail"
        let passwordKey = "userPassword"
        
        // Check if an item with the same email key already exists in the keychain
        let queryCheckEmail: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: emailKey
        ]
        
        var item: CFTypeRef?
        let statusCheckEmail = SecItemCopyMatching(queryCheckEmail as CFDictionary, &item)
        
        if statusCheckEmail == errSecSuccess {
            // Email already exists, update it
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: email.data(using: .utf8)!
            ]
            
            let statusUpdateEmail = SecItemUpdate(queryCheckEmail as CFDictionary, attributesToUpdate as CFDictionary)
            guard statusUpdateEmail == errSecSuccess else {
                print("Error updating email in keychain: \(statusUpdateEmail)")
                return
            }
        } else if statusCheckEmail == errSecItemNotFound {
            // Email does not exist, add it to the keychain
            let queryAddEmail: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: emailKey,
                kSecValueData as String: email.data(using: .utf8)!,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]
            
            let statusAddEmail = SecItemAdd(queryAddEmail as CFDictionary, nil)
            guard statusAddEmail == errSecSuccess else {
                print("Error adding email to keychain: \(statusAddEmail)")
                return
            }
        } else {
            // Unexpected error while checking email in keychain
            print("Error checking email in keychain: \(statusCheckEmail)")
            return
        }
        
        // Save password to the keychain
        let queryAddPassword: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: passwordKey,
            kSecValueData as String: password.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let statusAddPassword = SecItemAdd(queryAddPassword as CFDictionary, nil)
        guard statusAddPassword == errSecSuccess else {
            print("Error adding password to keychain: \(statusAddPassword)")
            return
        }
        
        print("Credentials saved to keychain")
    }
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"), let refreshToken = UserDefaults.standard.string(forKey: "refresh_token") else{
            return
        }
        
        let request = LogoutRequest(refresh_token: refreshToken)
        
        let domain = getRestUrl()
        guard let url = URL(string: "\(domain)/api/logicservice/user/logout/") else {
            return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (_, response, error) in
            self.isLoading = false
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.unknownError))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                UserDefaults.standard.reset()
                completion(.success(()))
            } else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
            }
            
        }.resume()
    }
}
     
            


extension LoginViewModel {
    func authenticateWithFaceID(completion: @escaping (Bool, String) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to log in"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Face ID authentication successful
                        if let credentials = self.retrieveCredentialsFromKeychain() {
                            self.email = credentials.email
                            self.password = credentials.password
                            completion(true, "Face ID authentication successful")
                        } else {
                            // No saved credentials found
                            completion(false, "No saved credentials found")
                        }
                    } else {
                        // Face ID authentication failed
                        if let error = authenticationError {
                            // Check specific error types and handle accordingly
                            switch error {
                            case LAError.userCancel, LAError.systemCancel:
                                completion(false, "Face ID authentication canceled")
                            default:
                                completion(false, "Face ID authentication failed")
                            }
                        }
                    }
                }
            }
        } else {
            // Face ID not available
            completion(false, "Face ID not available")
        }
    }
}


struct LogoutRequest: Encodable {
    let refresh_token: String
}

