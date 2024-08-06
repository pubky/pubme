//
//  ChatView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct ChatView: View {
    let chatId: String
    
    var body: some View {
        Text("chatId: \(chatId)")
    }
}

#Preview {
    ChatView(chatId: "123")
}
