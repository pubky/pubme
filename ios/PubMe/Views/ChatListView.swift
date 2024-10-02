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
    @State var showSettings = false
    
    var body: some View {
        list
            .navigationBarItems(leading: settingsButton)
            .navigationBarItems(trailing: addButton)
            .navigationTitle("Chats")
            .overlay {
                VStack {
                    Text("No Chat Groups")
                        .font(.title)
                        .padding()
                    NavigationLink(destination: ChatView(group: nil)) {
                        Label("Create New Group", systemImage: "plus.circle")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(viewModel.chatGroups?.count ?? 0 > 0 ? 0 : 1)
            }
            .overlay {
                VStack {
                    Spacer()
                    NavigationLink(destination: PubkeysView()) {
                        Label("Pubkeys", systemImage: "key.fill")
                    }
                }
            }
            .onAppear {
                Task { @MainActor in
                    await loadChatGroups()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .showError($errorMessage)
    }
    
    var settingsButton: some View {
//        NavigationLink(destination: SettingsView()) {
//            Image(systemName: "gear")
//        }
        Button(action: { showSettings.toggle() }) {
            Image(systemName: "gear")
        }
    }
    
    var addButton: some View {
        NavigationLink(destination: ChatView(group: nil)) {
            Image(systemName: "plus.circle")
        }
    }
    
    var list: some View {
        List(viewModel.chatGroups ?? []) { group in
            NavigationLink(destination: ChatView(group: group)) {
                HStack {
                    Image(systemName: "person.3")
                        .foregroundColor(Color("AccentColor"))
                    Text(group.shortId)
                        .font(.caption)
                }
//                .swipeActions() {
//                    Button(role: .destructive) {
//                        Task {
//                            do {
//                                try await viewModel.deleteChatGroup(group.id)
//                            } catch {
//                                errorMessage = error.localizedDescription
//                                await loadChatGroups()
//                            }
//                        }
//                    } label: {
//                        Label("Delete", systemImage: "trash")
//                    }
//                }
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
