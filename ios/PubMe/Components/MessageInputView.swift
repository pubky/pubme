//
//  MessageInputView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct MessageInputView: View {
    let groupId: String
    
    @Binding var keyboardOpen: Bool //TODO not needed?
    @State var message: String = ""
    @State var backgroundOpacity: Double = 0
    @State var isSending = false
    @State var errorMessage = ""
    
    @StateObject var viewModel = ViewModel.shared
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                TextField("Message...", text: $message)
                    .submitLabel(.return)
                    .disabled(isSending)
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .padding()
                }
                .disabled(isSending || !canSend)
            }
            .padding(.horizontal)
            .frame(height: 60)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.horizontal)
            .background(.clear)
        }
        .onChange(of: keyboardOpen) { newValue in
            withAnimation(.easeOut(duration: 0.2)) {
                backgroundOpacity =  newValue ? 1 : 0
            }
        }
        .showError($errorMessage)
    }
    
    var canSend: Bool {
        return message.replacing(" ", with: "") != "" && !isSending
    }
    
    func sendMessage() {
        guard canSend else {
            //Ignore empty messages
            return
        }
        
        isSending = true
        let messageToSend = message
        message = ""
        
        Task { @MainActor in
            do {
                let _ = try await viewModel.sendMessageTo(groupId: groupId, messageToSend)
            } catch {
                Logger.error(error)
                errorMessage = error.localizedDescription
                message = messageToSend //So they can retry
            }
            
            isSending = false
        }
    }
}


#Preview {
    MessageInputView(groupId: "test123", keyboardOpen: .constant(true))
}
