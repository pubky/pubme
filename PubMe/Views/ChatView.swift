//
//  ChatView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import UIKit
import SwiftUI

let closedKeyboardOffset: CGFloat = UIDevice.isIPad ? -60 : UIDevice.isIPhoneSE ? -40 : -10
let openKeyboardOffset: CGFloat = UIDevice.isIPad ? -60 : 40

struct ChatView: View {
    @State var group: ChatGroup?
    @State var isCreating = false
    @State var isSending = false
    @State var messages: [Message]? = nil
    @State var errorMessage = ""
    @State var isRefreshing = false
    
    @StateObject var viewModel = ViewModel.shared
    @ObservedObject private var keyboard = KeyboardResponder()

    @State private var pollTimer: Timer?
    
    let scrollViewId = "ChatScrollView"
    @State var yOffset: CGFloat = .zero
    @State var dragDownDistance: CGFloat = .zero
    @State var textInputOffset: CGFloat = closedKeyboardOffset

    
    var body: some View {
        ZStack {
            content
                .onTapGesture {
                    endEditing(true)
                }
            if let groupId = group?.id {
                MessageInputView(groupId: groupId, keyboardOpen: $keyboard.isOpen)
                    .offset(y: textInputOffset)
            }
        }
        .navigationTitle(group?.shortId ?? "Creating new chat...")
        .onAppear {
            if let _ = group {
                loadMessages()
            } else {
                createNewGroup()
            }
            
            startPolling()
        }
        .showError($errorMessage)
    }
    
    @ViewBuilder
    var content: some View {
        if let messages {
            ScrollViewReader { scrollView in
                VStack {
                    ScrollView(.vertical) {
                        scrollDetection
                        VStack {
                            ForEach(messages) { message in
                                MessageView(message: message, isCurrentUser: message.ownerPublicKey == viewModel.myPublicKey, chatId: group!.id)
                                    .listRowSeparator(.hidden)
                            }
                            listSpacer
                        }
                        .padding(.horizontal, 12)
                        .id(scrollViewId)
                    }
                    .onChange(of: keyboard.isOpen) { isOpen in
                        guard isOpen else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                scrollView.scrollTo(scrollViewId, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        scrollView.scrollTo(scrollViewId, anchor: .bottom)
                    }
                }
            }
            .coordinateSpace(name: ScrollDetector.name)
        }
    }
    
    var listSpacer: some View {
        Rectangle()
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .frame(width: 0, height: 70)
    }
    
    var scrollDetection: some View {
        Group {
            ScrollDetector()
            GeometryReader { proxy in
                let offset = proxy.frame(in: .named(ScrollDetector.name)).minY
                Color.clear.preference(key: ScrollPreferenceKey.self, value: offset)
            }
            .onPreferenceChange(ScrollPreferenceKey.self) { offset in
                if offset > yOffset {
                    //Scrolling down
                    dragDownDistance += offset-yOffset
                    if dragDownDistance > 120 {
                        endEditing(false)
                    }
                } else {
                    //Scrolling up cancels the drag
                    dragDownDistance = .zero
                }
                
                yOffset = offset
            }
        }
    }
    
    func createNewGroup() {
        isCreating = true
        Task { @MainActor in
            do {
                group = try await viewModel.createNewChatGroup()
                loadMessages()
                try? await viewModel.loadAllChatGroups() //So list is loaded when we navigate back
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isCreating = false
        }
    }
    
    func loadMessages() {
        guard let groupId = group?.id else {
            return
        }
        
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        Task { @MainActor in
            do {
                messages = try await viewModel.loadMessagesFor(groupId: groupId)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isRefreshing = false
        }
    }
    
    func sendMessage() {
        guard let groupId = group?.id else {
            return
        }
        
        isSending = true
        
        Task { @MainActor in
            do {
                let message = try await viewModel.sendMessageTo(groupId: groupId, "Hello the time is now \(Date.now.formatted())")
                //TODO instantly add message to list instead of waiting for reloading
                messages = try await viewModel.loadMessagesFor(groupId: groupId)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isSending = false
        }
    }
    
    func startPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            loadMessages()
        }
    }
    
    func stopPollimg() {
        pollTimer?.invalidate()
        pollTimer = nil
    }
}

extension View {
    func endEditing(_ force: Bool) {
        UIApplication.shared.windows.forEach { $0.endEditing(force)}
    }
}

struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollDetector: View {
    @ObservedObject var viewModel = ViewModel.shared
    
    static let name = "scroll"
    
    var body: some View {
        GeometryReader { proxy in
            let offset = proxy.frame(in: .named(ScrollDetector.name)).minY
            Color.clear.preference(key: ScrollPreferenceKey.self, value: offset)
        }
        .onPreferenceChange(ScrollPreferenceKey.self) { offset in
//            viewModel.showScrolledContentNav = offset < -40
        }
    }
}

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIPhoneSE: Bool {
        UIDevice.current.userInterfaceIdiom == .phone && UIScreen.screenHeight < 670
    }
}

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}



#Preview {
    ChatView(group: .init(publicKeys: ["1", "2", "3"]))
}
