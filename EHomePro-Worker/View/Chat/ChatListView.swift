//
//  ChatListView.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/5/24.
//

import SwiftUI
import Combine

struct ChatListView: View {
    
    @StateObject private var roomViewModel = RoomViewModel()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var timerCancellable: AnyCancellable?
    
    var body: some View {
        
        List(roomViewModel.rooms, id: \.id) { room in
            navigationLink(for: room)
        }
        .navigationTitle("Messages")
        .onAppear {
            if let workerId = UserDefaults.standard.string(forKey: "WorkerId") {
                roomViewModel.fetchRooms(for: Int(workerId)!)
            }
            startPolling()
        }
        .onDisappear {
            stopPolling()
        }
    }
    
    private func navigationLink(for room: RoomWithCustomer) -> some View {
        NavigationLink(destination: ChatDetailView(room: room)
            .navigationTitle(navigationTitle(for: room))) {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(room.customer.name)
                            .font(.headline)
                    }
                    Spacer()
                    Text("\(room.created_at.formattedDate())")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if room.has_unread_messages {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(.blue.opacity(0.60))
                    }
                }
            }
    }
    
    private func navigationTitle(for room: RoomWithCustomer) -> String {
        room.customer.name + " " + room.customer.lastName
    }
    
    private func startPolling() {
        timerCancellable = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if let workerId = UserDefaults.standard.string(forKey: "WorkerId") {
                    roomViewModel.fetchRooms(for: Int(workerId)!)
                }
            }
    }
    
    private func stopPolling() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}

#Preview {
    ChatListView()
}

