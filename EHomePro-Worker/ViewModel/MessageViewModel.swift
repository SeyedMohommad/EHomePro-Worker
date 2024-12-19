//
//  MessageViewModel.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/5/24.
//

import Foundation
import Combine

class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    private var unreadMessagesIds:[Int] = []
    private var cancellables = Set<AnyCancellable>()
    private var messageIds = Set<Int>() // To track the IDs of the messages
    
    func fetchMessages(before time: String, for roomId: Int) {
        isLoading = true
        MessageService.shared.fetchMessages(before: time, for: roomId)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { newMessages in
                self.addUniqueMessages(newMessages)
            }
            .store(in: &cancellables)
    }
    
    func fetchMessages(after time: String, for roomId: Int) {
        
        MessageService.shared.fetchMessages(after: time, for: roomId)
            .sink { completion in
                if case let .failure(error) = completion {
                    
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { newMessages in
                self.addUniqueMessages(newMessages)
            }
            .store(in: &cancellables)
    }
    
    func sendMessage(_ message: Message) {
        print("vm sendMessage called with: \(message)")
        isLoading = true
        MessageService.shared.sendMessage(message: message)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error in sendMessage: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] message in
                print("Message sent successfully: \(message)")
                
                self?.messages.append(message)
            }
            .store(in: &cancellables)
    }
    
    
    func fetchMessageById(_ id: Int) {
        isLoading = true
        MessageService.shared.fetchMessageById(id)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error in fetchMessageById: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] message in
                self?.messages.append(message)
                print("Message fetched successfully: \(message)")
            }
            .store(in: &cancellables)
    }

    
    
    func makeMessageDelivered(messageIds: [Int]) {
        isLoading = true
        MessageService.shared.makeMessageDelivered(messageIds: unreadMessagesIds)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error in makeMessageDelivered: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] in
                print("Messages delivered successfully")
                // Handle any additional logic here if needed
            }
            .store(in: &cancellables)
    }
    
    func sendMessageWithImage(_ message: Message, imageData: Data, imageName: String) {
        isLoading = true
        
        MessageService.shared.sendMessageWithImage(message: message, imageData: imageData, imageName: imageName)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error in sendMessageWithImage: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] message in
                print("Message with image sent successfully: \(message)")
                self?.messages.append(message)
            }
            .store(in: &cancellables)
    }

    
    private func addUniqueMessages(_ newMessages: [Message]) {
        self.isLoading = false
        let workerId = UserDefaults.standard.string(forKey: "WorkerId")
        for message in newMessages {
            if !messageIds.contains(message.id!) {
                messages.append(message)
                if !message.isDelivered && message.senderId != Int(workerId!) {
                    unreadMessagesIds.append(Int(message.id!))
                }
                messageIds.insert(message.id!)
            }
            
        }
        if !unreadMessagesIds.isEmpty {
            makeMessageDelivered(messageIds: unreadMessagesIds)
        }
        
    }
}
