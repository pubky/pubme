//
//  ChatView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct ChatView: View {
    @State var groupId: String?
    @State var isCreating = false
    @State var errorMessage = ""
    
    @StateObject var viewModel = ViewModel.shared
    
    var body: some View {
        HStack {
            Text(groupId ?? "Creating new chat...")
                .font(.caption2)
        }
        .onAppear {
            if let groupId {
                //TODO load chat
            } else {
                createNewGroup()
            }
        }
        .showError($errorMessage)
    }
    
    func createNewGroup() {
        isCreating = true
        Task { @MainActor in
            do {
                groupId = try await viewModel.createNewChatGroup()
                await loadMessages()
                try? await viewModel.loadAllChatGroups() //So list is loaded when we navigate back
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isCreating = false
        }
    }
    
    func loadMessages() async {
        
    }
}

#Preview {
    ChatView(groupId: "123")
}
