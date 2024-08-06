//
//  ChatView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct ChatView: View {
    @State var group: ChatGroup?
    @State var isCreating = false
    @State var isSending = false
    @State var messages: [Message]? = nil
    @State var errorMessage = ""
    @State var isRefreshing = false
    
    @StateObject var viewModel = ViewModel.shared
    
    @State private var pollTimer: Timer?
    
    var body: some View {
        List {
            if let messages = messages {
                ForEach(messages) { message in
                    Text(message.body.text)
                }
            }
        }
        .overlay {
            Button {
                sendMessage()
            } label: {
                Label("Send test message", systemImage: "paperplane")
            }
            .disabled(isSending)
        }
        .navigationTitle(group?.shortId ?? "Creating new chat...")
        .onAppear {
            if let group {
                //TODO load chat
                loadMessages()
            } else {
                createNewGroup()
            }
            
            startPolling()
        }
        .showError($errorMessage)
    }
    
    func createNewGroup() {
        isCreating = true
        Task { @MainActor in
            do {
                group = try await viewModel.createNewChatGroup()
                loadMessages()
                try? await viewModel.loadAllChatGroups() //So list is loaded when we navigate back
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isCreating = false
        }
    }
    
    func loadMessages() {
        guard let groupId = group?.id else {
            return
        }
        
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        Task { @MainActor in
            do {
                messages = try await viewModel.loadMessagesFor(groupId: groupId)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isRefreshing = false
        }
    }
    
    func sendMessage() {
        guard let groupId = group?.id else {
            return
        }
        
        isSending = true
        
        Task { @MainActor in
            do {
                let message = try await viewModel.sendMessageTo(groupId: groupId, "Hello the time is now \(Date.now.formatted())")
                //TODO instantly add message to list instead of waiting for reloading
                messages = try await viewModel.loadMessagesFor(groupId: groupId)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isSending = false
        }
    }
    
    func startPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            loadMessages()
        }
    }
    
    func stopPollimg() {
        pollTimer?.invalidate()
        pollTimer = nil
    }
}

#Preview {
    ChatView(group: .init(publicKeys: ["1", "2", "3"]))
}
