//
//  ChatViewModel.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

enum ViewModelErrors: Error {
    case missingKey
}

@MainActor
class ViewModel: ObservableObject {
    @Published var keypairExists: Bool? = nil
    @Published var chatGroups: [ChatGroup]? = nil
    @Published var myPublicKey = ""
    
    @AppStorage("friendsPublicKeys") var friendsPublicKeys = "" // | separated list
    @AppStorage("homeServerPublicKey") var homeServerPublicKey = Env.defaultHomeServer
    
    private init() {}
    public static var shared = ViewModel()
    
    func setKeypairExistsState() async throws {
        do {
            let exists = try Keychain.exists(key: .secretKey) && Keychain.exists(key: .publicKey)
            
            if exists {
                try await setupClient()
                myPublicKey = try Keychain.loadString(key: .publicKey)!
            }
            
            keypairExists = exists
            
        } catch {
            //TODO show error
            Logger.error(error)
        }
    }
    
    func createKeyPair() async throws {
        let keypair = try await PubkyClientProxy.shared.generateKeyPair()
        try Keychain.saveString(key: .publicKey, str: keypair.publicKey)
        try Keychain.saveString(key: .secretKey, str: keypair.secretKey)
        try await setKeypairExistsState()
    }
    
    func setupClient() async throws {
        guard let secretKey = try Keychain.loadString(key: .secretKey) else {
            throw ViewModelErrors.missingKey
        }
        try await PubkyClientProxy.shared.signup(secretKey: secretKey, homeServerPublicKey: homeServerPublicKey)
    }
    
    func loadAllChatGroups() async throws {
        if Env.isPreview {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.chatGroups = [
                    ChatGroup(id: UUID().uuidString, publicKeys: [UUID().uuidString, UUID().uuidString, UUID().uuidString]),
                    ChatGroup(id: UUID().uuidString, publicKeys: [UUID().uuidString, UUID().uuidString])
                ]
            }
            return
        }
        
        guard let myPublicKey = try Keychain.loadString(key: .publicKey) else {
            throw ViewModelErrors.missingKey
        }
        
        var groupIds = try await loadChatGroupsFor(publicKey: myPublicKey)
        
        //Load all friend's public keys
        let friends = getFriendsPublicKeys()
        for friend in friends {
            let friendGroups = try await loadChatGroupsFor(publicKey: friend)
            groupIds.append(contentsOf: friendGroups)
        }
        
        chatGroups = Array(Set(groupIds)).sorted().map { ChatGroup(id: String($0), publicKeys: []) }
    }
    
    private func loadChatGroupsFor(publicKey: String) async throws -> [String] {
        Logger.info("Loading chat groups for \(publicKey)")
        
        let appDatastore = PubkyClientProxy.chatStoreUrl(publicKey: publicKey)
        
        let urls = try await PubkyClientProxy.shared.list(url: appDatastore)
        
        return urls
            .map { $0.replacingOccurrences(of: appDatastore, with: "").split(separator: "/").first ?? "" }
            .compactMap { String($0) }
            .filter { !$0.isEmpty }
    }
    
    func createNewChatGroup() async throws -> ChatGroup {
        guard let publicKey = try Keychain.loadString(key: .publicKey) else {
            throw ViewModelErrors.missingKey
        }
        
        let chatId = UUID().uuidString
        
        try await PubkyClientProxy.shared.put(
            publicKey: publicKey,
            url: PubkyClientProxy.chatStoreUrl(publicKey: publicKey, chatId: chatId, messageId: "message-1"),
            body: Message.initNewSendMessage("\(publicKey) started a new chat", ownPublicKey: publicKey).toString()
        )
        
        //TODO: load friends pubkeys
        return .init(id: chatId, publicKeys: [])
    }
    
    func loadMessagesFor(groupId: String) async throws -> [Message] {
        if Env.isPreview {
            return [
                .initNewSendMessage("Hey there", ownPublicKey: "123"),
                .initNewSendMessage("Hello", ownPublicKey: "234"),
                .initNewSendMessage("How are you?", ownPublicKey: "345"),
            ]
        }
        
        guard let myPublicKey = try Keychain.loadString(key: .publicKey) else {
            throw ViewModelErrors.missingKey
        }
        
        //Load all messages from own and friends stores
        let publicKeys = [myPublicKey] + getFriendsPublicKeys()
        
        let urls = publicKeys.map({ PubkyClientProxy.chatStoreUrl(publicKey: $0, chatId: groupId) })
        var messages: [Message] = []

        for url in urls {
            let messageUrls = try await PubkyClientProxy.shared.list(url: url)
            
            Logger.info("Loading messages for \(groupId) [\(messageUrls.count)]")
            
            for url in messageUrls {
                let messageData = try await PubkyClientProxy.shared.get(url: url)
                messages.append(try Message.initFromString(String(data: messageData, encoding: .utf8)!))
            }
        }
        
        messages.sort { $0.body.timestamp < $1.body.timestamp }
        
        return messages
    }
    
    func sendMessageTo(groupId: String, _ text: String) async throws -> Message {
        guard let publicKey = try Keychain.loadString(key: .publicKey) else {
            throw ViewModelErrors.missingKey
        }
        
        let message = Message.initNewSendMessage(text, ownPublicKey: publicKey)
        
        try await PubkyClientProxy.shared.put(
            publicKey: publicKey,
            url: PubkyClientProxy.chatStoreUrl(publicKey: publicKey, chatId: groupId, messageId: message.id),
            body: message.toString()
        )
        
        return message
    }
    
    func deleteMessage(_ message: Message, chatId: String) async throws {
        guard let publicKey = try Keychain.loadString(key: .publicKey) else {
            throw ViewModelErrors.missingKey
        }
        
        try await PubkyClientProxy.shared.delete(
            publicKey: publicKey,
            url: PubkyClientProxy.chatStoreUrl(publicKey: publicKey, chatId: chatId, messageId: message.id)
        )
    }
    
    func getFriendsPublicKeys() -> [String] {
        self.friendsPublicKeys.split(separator: "|").map { String($0) }
    }
    
    func addFriendPublicKey(_ publicKey: String) {
        var currentList = getFriendsPublicKeys()
        guard !currentList.contains(publicKey) else {
            return
        }
        
        currentList.append(publicKey)
        friendsPublicKeys = currentList.joined(separator: "|")
    }
}
