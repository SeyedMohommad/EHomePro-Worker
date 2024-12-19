//
//  AdditionalInfoViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 11/20/24.
//

import Foundation
import Combine
import UIKit

class AdditionalInfoViewModel: ObservableObject {
    @Published var additionalInfoList: [AdditionalInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()
//    private var orderId: Int

//    init(orderId: Int) {
//        self.orderId = orderId
//    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    /// Creates a new Additional Info (Step 1)
    func createAdditionalInfo(description: String, workerId: Int,orderId: Int ,completion: @escaping (AdditionalInfo?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        
        
        
        
        let urlString = "\(getRestUrl())/api/logicservice/additionalinfo/"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL."
            }
            completion(nil)
            return
        }

        
        let additionalInfo = AdditionalInfo(id: 0, description: description, pictureUrls: [], orderId: orderId, workerId: workerId)
        guard let requestData = try? JSONEncoder().encode(additionalInfo) else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to encode data."
            }
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AdditionalInfo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionStatus in
                self?.isLoading = false
                switch completionStatus {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "Failed to create additional info: \(error.localizedDescription)"
                    completion(nil)
                }
            } receiveValue: { [weak self] newInfo in
                print("Created AdditionalInfo: \(newInfo)")
                self?.additionalInfoList.append(newInfo)
                completion(newInfo)
            }
            .store(in: &cancellables)
    }

    /// Uploads pictures one by one for the Additional Info (Step 2)
    func uploadPicturesSequentially(id: Int, images: [Data], completion: @escaping (Bool) -> Void) {
        let urlString = "\(getRestUrl())/api/logicservice/additionalinfo/uploadpicture/\(id)/"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL."
            }
            completion(false)
            return
        }

        var currentIndex = 0

        func uploadNext() {
            guard currentIndex < images.count else {
                completion(true) // All uploads succeeded
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            guard let token = UserDefaults.standard.string(forKey: "access_token") else {
                print("No access token found")
                completion(false)
                return
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            let compressedData = UIImage(data: images[currentIndex])?.jpegData(compressionQuality: 0.5) ?? images[currentIndex]
            let body = createMultipartBody(image: compressedData, boundary: boundary)
            request.httpBody = body

            isLoading = true
            errorMessage = nil

            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response -> Bool in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw URLError(.badServerResponse)
                    }
                    if !(200...299).contains(httpResponse.statusCode) {
                        let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                        print("Error uploading image: HTTP \(httpResponse.statusCode), Response: \(responseBody)")
                        throw URLError(.badServerResponse)
                    }
                    return true
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completionStatus in
                    self?.isLoading = false
                    switch completionStatus {
                    case .finished:
                        print("Successfully uploaded image \(currentIndex + 1)")
                        currentIndex += 1
                        uploadNext() // Upload the next image
                    case .failure(let error):
                        self?.errorMessage = "Failed to upload image \(currentIndex + 1): \(error.localizedDescription)"
                        print("Failed to upload image \(currentIndex + 1): \(error.localizedDescription)")
                        completion(false) // Stop uploading on failure
                    }
                } receiveValue: { _ in
                    // Optional: Handle success response value
                }
                .store(in: &cancellables)
        }

        uploadNext()
    }

    /// Fetches the additional info by ID (Step 3)
    func fetchAdditionalInfoById(id: Int, completion: @escaping (AdditionalInfo?) -> Void) {
        let urlString = "\(getRestUrl())/api/logicservice/additionalinfo/\(id)/"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL."
            }
            completion(nil)
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AdditionalInfo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completionStatus in
                self?.isLoading = false
                switch completionStatus {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch additional info: \(error.localizedDescription)"
                    completion(nil)
                }
            } receiveValue: { fetchedInfo in
                print("Fetched AdditionalInfo: \(fetchedInfo)")
                completion(fetchedInfo)
            }
            .store(in: &cancellables)
    }

    /// Helper to create multipart body for a single image
    func createMultipartBody(image: Data, boundary: String) -> Data {
        var body = Data()
        
        let lineBreak = "\r\n"
        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(image)
        body.append("\(lineBreak)--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        
        return body
    }
}

// Add helper to append string to Data
private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
