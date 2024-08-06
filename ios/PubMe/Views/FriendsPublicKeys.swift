//
//  FriendsPublicKeys.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct FriendsPublicKeys: View {
    @StateObject var viewModel = ViewModel.shared
    
    @State var newPublicKey = ""
    
    @State var errorMessage = ""
    
    var body: some View {
        Form {
            Section("Add new") {
                TextField("Public key", text: $newPublicKey)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                Button {
                    viewModel.addFriendPublicKey(newPublicKey)
                    newPublicKey = ""
                    
                    //Reload with pubkeys we now know
                    Task { @MainActor in
                        try? await viewModel.loadAllChatGroups()
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            
            Section("Existing") {
                existingList
            }
        }
        .navigationTitle("Friends Public Keys")
        
        
    }
    
    @ViewBuilder
    var existingList: some View {
        if viewModel.friendsPublicKeys.isEmpty {
            Text("No friends public keys")
        } else {
            let list = viewModel.getFriendsPublicKeys()
            ForEach(list, id: \.self) { key in
                Text(key)
            }
        }
    }
}

#Preview {
    FriendsPublicKeys()
}
