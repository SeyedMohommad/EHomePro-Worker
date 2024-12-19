//
//  ImageViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/30/24.
//

import SwiftUI
import Combine
import UIKit


class ImageService: ObservableObject {
    static let shared = ImageService()
    @Published private var imageViewModel = ImageViewModel()
    
    private init() {}
    
    func loadImage(fileName: String) {
        imageViewModel.loadImage(fileName: fileName)
    }
    func loadProfileImage(fileName: String) -> UIImage? {
        
        return imageViewModel.loadProfImage(fileName: fileName)
    }
    
    var image: UIImage? {
        return imageViewModel.image
    }
    
    var isLoading: Bool {
        return imageViewModel.isLoading
    }
    
    var imagePublisher: Published<UIImage?>.Publisher {
        return imageViewModel.$image
    }
    
    func localImageURL(fileName: String) -> URL? {
        return imageViewModel.localImageURL(fileName: fileName)
    }
}

class ImageViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading: Bool = false
    private var cancellable: AnyCancellable?
    private var currentImageURL: URL?
    
    init() {}
    
    func loadProfImage(fileName: String) -> UIImage? {
        
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return nil
        }
        
        let domain = getRestUrl()
        guard let url = URL(string: "\(domain)/api/logicservice/amazons3/view/\(fileName)/") else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Check if image exists in cache
        if let cachedImage = ImageCache.shared.image(for: url) {
            return cachedImage
        }
        
        // Fetch image from internet
        var loadedImage: UIImage?
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }
            guard let data = data, error == nil else {
                print("Failed to load image from network: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            loadedImage = UIImage(data: data)
            if let loadedImage = loadedImage {
                ImageCache.shared.saveImage(loadedImage, for: url) // Cache the image
            }
        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        return loadedImage
    }
    
    
    
    func loadImage(fileName: String) {
        
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let domain = getRestUrl()
        guard let url = URL(string: "\(domain)/api/logicservice/amazons3/view/\(fileName)/") else {
            print("Invalid URL")
            return
        }
        currentImageURL = url
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Check if image exists in cache
        if let cachedImage = ImageCache.shared.image(for: url) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.image = cachedImage
                self.isLoading = false
            }
            return
        }
        
        // If not in cache, fetch from internet
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main) // Update on the main thread
            .sink { [weak self] image in
                print("Image loaded from network: \(image != nil)")
                guard let self = self else { return }
                self.isLoading = false
                if let image = image {
                    self.image = image
                    ImageCache.shared.saveImage(image, for: url) // Cache the image
                }
            }
    }
    
    func loadImageWithHandler(fileName: String, completion: @escaping (UIImage?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            completion(nil)
            return
        }
        
        let domain = getRestUrl()
        guard let url = URL(string: "\(domain)/api/logicservice/amazons3/view/\(fileName)/") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        currentImageURL = url
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Check if image exists in cache
        if let cachedImage = ImageCache.shared.image(for: url) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        // If not in cache, fetch from internet
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main) // Update on the main thread
            .sink { [weak self] image in
                
                guard let self = self else { return }
                self.isLoading = false
                if let image = image {
                    self.image = image
                    ImageCache.shared.saveImage(image, for: url) // Cache the image
                }
                completion(image)
            }
    }
    
    func localImageURL(fileName: String) -> URL? {
        guard let url = currentImageURL else { return nil }
        return ImageCache.shared.localImageURL(for: url)
    }
    
    
    
    
}

class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSURL, UIImage>()
    
    func image(for url: URL) -> UIImage? {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        } else if let localImage = loadLocalImage(for: url) {
            return localImage
        } else {
            return nil
        }
    }
    
    func saveImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
        saveImageToLocal(image, for: url)
    }
    
    private func loadLocalImage(for url: URL) -> UIImage? {
        guard let localURL = localURL(for: url) else { return nil }
        return UIImage(contentsOfFile: localURL.path)
    }
    
    private func saveImageToLocal(_ image: UIImage, for url: URL) {
        guard let localURL = localURL(for: url),
              let data = image.jpegData(compressionQuality: 1.0) else { return }
        try? data.write(to: localURL)
    }
    
    private func localURL(for url: URL) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsDirectory?.appendingPathComponent(url.lastPathComponent)
    }
    
    func localImageURL(for url: URL) -> URL? {
        return localURL(for: url)
    }
}
