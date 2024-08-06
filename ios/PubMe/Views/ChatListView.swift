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
            } else {
                loader
            }
        }
        .overlay {
            VStack {
                Text("No Chat Groups")
                    .font(.title)
                    .padding()
                NavigationLink(destination: ChatView(group: nil)) {
                    Label("Create New Group", systemImage: "plus.circle")
                }
            }
            .opacity(viewModel.chatGroups?.count ?? 0 > 0 ? 0 : 1)
        }
        .overlay {
            
            VStack {
                Spacer()
                NavigationLink(destination: FriendsPublicKeys()) {
                    Label("Friend pubkeys", systemImage: "key.fill")
                }
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
        NavigationLink(destination: ChatView(group: nil)) {
            Image(systemName: "plus.circle")
        }
    }
    
    var list: some View {
        List(viewModel.chatGroups!) { group in
            NavigationLink(destination: ChatView(group: group)) {
                HStack {
                    Image(systemName: "person.3")
                        .foregroundColor(Color("AccentColor"))
                    Text(group.shortId)
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
