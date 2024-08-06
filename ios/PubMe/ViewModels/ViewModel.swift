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
        guard let publicKey = try Keychain.loadString(key: .publicKey) else {
            throw ViewModelErrors.missingKey
        }
        
        let urls = try await PubkyClientProxy.shared.list(url: PubkyClientProxy.chatStoreUrl(publicKey: publicKey))
        
        //TODO add all friend's public keys
        chatGroups = urls.map { ChatGroup(id: $0, url: $0, publicKeys: []) }
    }
    
    func createNewChatGroup() async throws {
        
    }
}
