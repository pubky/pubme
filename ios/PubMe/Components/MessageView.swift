//
//  MessageView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct MessageView : View {
    let message: Message
    let isCurrentUser: Bool
    let chatId: String
    
    var body: some View {
        let colorSet1 = [Color("AccentColor"), Color("AccentColor").opacity(0.8)]
        let colorSet2 = [Color.gray.opacity(0.3), Color.gray.opacity(0.4)]
        
        HStack(alignment: .bottom, spacing: 15) {
            if isCurrentUser {
                Spacer()
            }
            
            ContentMessageView(
                contentMessage: message.body.text,
                isCurrentUser: isCurrentUser
            )

            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(LinearGradient(colors: isCurrentUser ? colorSet1 : colorSet2, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .opacity(0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .contextMenu {
                if isCurrentUser {
                    menuItems
                }
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
    
    var menuItems: some View {
        Group {
            Button {
                Task {
                    try? await ViewModel.shared.deleteMessage(message, chatId: chatId)
                }
            } label: {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}

struct ContentMessageView: View {
    var contentMessage: String
    var isCurrentUser: Bool
    
    var body: some View {
        Text(contentMessage)
            .padding(10)
//            .foregroundColor(Color("AccentColor"))
    }
}

#Preview {
    ScrollView {
        MessageView(message: .initNewSendMessage("Hey there sailor", ownPublicKey: "123"), isCurrentUser: true, chatId: "")
        MessageView(message: .initNewSendMessage("Ahoy!", ownPublicKey: "123"), isCurrentUser: false, chatId: "")
    }
    .padding()
}
