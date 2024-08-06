//
//  ChatList.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct ChatList: View {
    @State var errorMessage = ""
    @StateObject var viewModel = ViewModel.shared
    
    var body: some View {
        Group {
            if let groups = viewModel.chatGroups {
                if groups.count == 0 {
                    Text("No Chat Groups")
                        .font(.title)
                        .padding()
                    Button(action: {
                        Task {

                        }
                    }, label: {
                        Label("Create New Group", systemImage: "plus.circle")
                    })
                } else {
                    list
                }
            } else {
                loader
            }
        }
        .showError($errorMessage)
    }
    
    var list: some View {
        List(viewModel.chatGroups!) { group in
            NavigationLink(destination: ChatView(chatId: group.id)) {
                Text(group.url)
            }
        }
        .refreshable {
            await loadChatGroups()
        }
    }
    
    var loader: some View {
        ProgressView("Loading Chat Groups...")
            .onAppear {
                Task { @MainActor in
                    await loadChatGroups()
                }
            }
    }
    
    func loadChatGroups() async {
        do {
            try await viewModel.loadAllChatGroups()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ChatList()
}
