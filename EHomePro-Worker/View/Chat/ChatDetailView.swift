//
//  ChatDetailView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/5/24.
//

import SwiftUI
import Combine
import ExyteChat // Import Exyte Chat framework

struct ChatDetailView: View {
    var room: RoomWithCustomer
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""

    @StateObject private var imageService = ImageService.shared
    
    @StateObject private var messageViewModel = MessageViewModel()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var timerCancellable: AnyCancellable?
    @State private var isTheFirstAppear = true
    @State private var profileImage:UIImage?
    
    var body: some View {
        ZStack {
            ChatView(messages: messages.map(mapToExyteMessage)) { draft in
                Task {
                    await sendMessage(draft: draft)
                }
                
            }
            
            .navigationBarItems(trailing: Image(uiImage: profileImage ?? UIImage(systemName: "person.circle")!)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle()))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isTheFirstAppear = false
                
                loadProfileImage()
                fetchMessages()
                subscribeToMessages()
                startPolling()
            }
            .onDisappear {
                stopPolling()
            }
            if messageViewModel.isLoading {
                MyProgressView()
            }
            
        }
    }
    
    
    private func mapToExyteMessage(_ message: Message) -> ExyteChat.Message {
        var uniqueIdGenerator: Int = 0

        func generateUniqueId() -> String {
            uniqueIdGenerator += 1
            return "\(uniqueIdGenerator)"
        }
        let dateComponentsArray = message.sentAt
        var dateComponents = DateComponents()
        dateComponents.year = dateComponentsArray[0]
        dateComponents.month = dateComponentsArray[1]
        dateComponents.day = dateComponentsArray[2]
        dateComponents.hour = dateComponentsArray[3]
        dateComponents.minute = dateComponentsArray[4]
        dateComponents.second = dateComponentsArray[5]
        
        let current = Calendar.current
        
        let isCurrentUser = (message.userType == .worker)
        print("message.userType: \(message.userType)")
        var avatarUrl:URL?
        
        if let fileName = room.customer.profilePicture {
            avatarUrl = ImageService.shared.localImageURL(fileName: fileName)
        }else{
            print("failed to make user avartar url")
        }
        var replyMessage: ReplyMessage?
        if message.replyToMessage_id != nil {
            for vmMessage in messageViewModel.messages {
                if vmMessage.id == message.replyToMessage_id {
                    let repMessage = mapToExyteMessage(vmMessage)
                    replyMessage = ReplyMessage(id: repMessage.id, user: repMessage.user,text: repMessage.text)
                }
            }
            
        }
        
        if message.messageType == "PHOTO" {
            ImageService.shared.loadImage(fileName: message.value)
//            ExyteChat.Message(id: <#T##String#>, user: <#T##User#>, replyMessage: ReplyMessage)
            return ExyteChat.Message(
                id: String(message.id ?? 0),
                user: ExyteChat.User(id: String(message.senderId), name: "", avatarURL: avatarUrl, isCurrentUser: isCurrentUser),
                status: message.isDelivered ? .read : .sent,
                createdAt: current.date(from: dateComponents)!,
                text: "",
                attachments: [Attachment.init(id: generateUniqueId(), url: ImageService.shared.localImageURL(fileName: message.value)!, type: .image)],
                recording: nil,
                replyMessage: replyMessage
            )

        }
        
//        if message.replyToMessage_id != nil {
//            for vmMessage in messageViewModel.messages {
//                if vmMessage.id == Int(message.replyToMessage_id!) {
//                    replyMessage = ReplyMessage(id: String(vmMessage.id!), user: ExyteChat.User(id: String(message.senderId), name: "", avatarURL: avatarUrl, isCurrentUser: isCurrentUser),text: vmMessage.value)
//                }
//            }
//
//        }
        
        return ExyteChat.Message(
            id: String(message.id ?? 0),
            user: ExyteChat.User(id: String(message.senderId), name: "", avatarURL: avatarUrl, isCurrentUser: isCurrentUser),
            status: message.isDelivered ? .read : .sent,
            createdAt: current.date(from: dateComponents)!,
            text: message.value,
            attachments: [],
            recording: nil,
            replyMessage: replyMessage
        )
    }
    
    private func loadProfileImage() {
        guard let fileName = room.customer.profilePicture else { return }
        
        profileImage = ImageService.shared.loadProfileImage(fileName: fileName)
    }
    
    private func fetchMessages() {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let time = isoFormatter.string(from: room.created_at)
        print("creation time: \(time)")
        messageViewModel.fetchMessages(after: time, for: room.id)
        
    }
    
    private func subscribeToMessages() {
        messageViewModel.$messages
            .receive(on: RunLoop.main)
            .sink { newMessages in
                for newMessage in newMessages {
                    if !self.messages.contains(where: { $0.id == newMessage.id }) {
                        
                        self.messages.append(newMessage)
                    }
                }
            }
            .store(in: &cancellables)
    }

//    private func subscribeToMessages() {
//            messageViewModel.$messages
//                .receive(on: RunLoop.main)
//                .sink { messages in
//                    self.messages = messages
//                }
//                .store(in: &cancellables)
//        }

    
    private func startPolling() {
        timerCancellable = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.fetchMessages()
            }
    }
    
    private func stopPolling() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func sendMessage(draft: DraftMessage) async {
        let isoFormatter = ISO8601DateFormatter()
        let currentTimeString = isoFormatter.string(from: Date())

        if let date = isoFormatter.date(from: currentTimeString) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            let second = calendar.component(.second, from: date)
            let nanosecond = calendar.component(.nanosecond, from: date)
            let millisecond = nanosecond / 1_000_000
            let dateComponents: [Int] = [year, month, day, hour, minute, second, millisecond]
//            print("draft.replyMessage.id\(draft.replyMessage?.id)")
            var replyMessage:ReplyMessage?
            if draft.replyMessage != nil {
                for vmMessage in messageViewModel.messages {
                    if vmMessage.value == draft.replyMessage?.text {
                        replyMessage = draft.replyMessage                    }
                }
                
            }
            if draft.medias.isEmpty {
                var replyMessageID: Int?
                if replyMessage != nil {
                    replyMessageID = Int(replyMessage!.id)
                }
                let message = Message(
                    id: nil,
                    roomId: room.id,
                    senderId: Int(room.worker_id),
                    value: draft.text,
                    userType: .worker,
                    messageType: "TEXT",
                    sentAt: dateComponents,
                    isDelivered: false,
                    replyToMessage_id: replyMessageID
                )
                messageViewModel.sendMessage(message)
            } else {
                
                var replyMessageID: Int?
                if replyMessage != nil {
                    replyMessageID = Int(replyMessage!.id)
                }
                // Handling image media
                for media in draft.medias {
                    if media.type == .image {
                        let imgData = await media.getData()
                        let imageName = UUID().uuidString + ".jpg"
                        let message = Message(
                            id: nil,
                            roomId: room.id,
                            senderId: Int(room.worker_id),
                            value: imageName,
                            userType: .worker,
                            messageType: "PHOTO",
                            sentAt: dateComponents,
                            isDelivered: false,
                            replyToMessage_id: replyMessageID
                        )
                        
                        messageViewModel.sendMessageWithImage(message, imageData: imgData!, imageName: imageName)
                        
                        
                        
                    }else{
                        print("Currently, we do not support this type of media ")
                    }
                    
                    
                }
                if !draft.text.isEmpty {
                    var replyMessageID: Int?
                    if replyMessage != nil {
                        replyMessageID = Int(replyMessage!.id)
                    }
                    let message = Message(
                        id: nil,
                        roomId: room.id,
                        senderId: Int(room.worker_id),
                        value: draft.text,
                        userType: .worker,
                        messageType: "TEXT",
                        sentAt: dateComponents,
                        isDelivered: false,
                        replyToMessage_id: replyMessageID
                    )
                    messageViewModel.sendMessage(message)
                }
            }

            newMessage = ""
        } else {
            print("Invalid date string")
        }
    }

}
