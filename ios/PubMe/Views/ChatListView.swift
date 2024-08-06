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
                    .navigationBarItems(trailing: addButton)
                    .navigationTitle("Pubme")
                    .overlay {
                        if groups.count == 0 {
                            VStack {
                                Text("No Chat Groups")
                                    .font(.title)
                                    .padding()
                                
                                NavigationLink(destination: ChatView(groupId: nil)) {
                                    Label("Create New Group", systemImage: "plus.circle")
                                }
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
    
    var addButton: some View {
        NavigationLink(destination: ChatView(groupId: nil)) {
            Image(systemName: "plus.circle")
        }
    }
    
    
    var list: some View {
        List(viewModel.chatGroups!) { group in
            NavigationLink(destination: ChatView(groupId: group.id)) {
                HStack {
                    Image(systemName: "person.3")
                        .foregroundColor(Color("AccentColor"))
                    Text(group.id.split(separator: "-").first ?? "Unknown")
                        .font(.caption)
                }
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
