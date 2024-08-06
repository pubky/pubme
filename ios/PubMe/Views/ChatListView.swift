//
//  ChatListView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct ChatListView: View {
    @State var errorMessage = ""
    @StateObject var viewModel = ViewModel.shared
    
    var body: some View {
        Group {
            if let groups = viewModel.chatGroups {
                list
                    .navigationBarItems(leading: settingsButton)
                    .navigationBarItems(trailing: qrButton)
                    .navigationTitle("Pubme")
                    .overlay {
                        if groups.count == 0 {
                            VStack {
                                Text("No Chat Groups")
                                    .font(.title)
                                    .padding()
                                Button(action: {
                                    Task { @MainActor in
                                        
                                    }
                                }, label: {
                                    Label("Create New Group", systemImage: "plus.circle")
                                })
                            }
                        }
                    }
            } else {
                loader
            }
        }
        .onAppear {
            Task { @MainActor in
                await loadChatGroups()
            }
        }
        .showError($errorMessage)
    }
    
    var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gear")
        }
    }
    
    var qrButton: some View {
        NavigationLink(destination: MyPubkyView(publicKey: viewModel.myPublicKey)) {
            Image(systemName: "qrcode")
        }
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
    ChatListView()
}
