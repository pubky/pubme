//
//  PubkeyClient.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/10/02.
//

import Foundation

struct Keypair: Codable {
    let secret_key: String
    let public_key: String
    let uri: String
}

enum PubkyClientError: Error {
    case invalidResult
    case invalidJson
}

class PubkyClient {
    static let shared = PubkyClient()
    private init() {}
    
    private func validateResult(_ result: [String]) throws {
        if result.count != 2 || result[0] != "success" {
            Logger.error(result, context: "PubkyClient result")
            throw PubkyClientError.invalidResult
        }
    }
    
    func generateKeyPair() async throws -> Keypair {
        let result = generateSecretKey()
        try validateResult(result)
        
        guard let jsonData = result[1].data(using: .utf8) else {
            throw PubkyClientError.invalidResult
        }
        
        return try JSONDecoder().decode(Keypair.self, from: jsonData)
    }
    
    func signup(secretKey: String, homeServerPublicKey: String) async throws {
        let result = signUp(secretKey: secretKey, homeserver: homeServerPublicKey)
        try validateResult(result)
        
        Logger.info("Signed up")
    }
    
    func putC(url: String, body: String) async throws {
        let result = put(url: url, content: body)
        try validateResult(result)
    }
    
    // Lists all URLs
    func listC(url: String) async throws -> [String] {
        let result = list(url: url)
        try validateResult(result)
        
        Logger.info(result[1])
        
        let jsonStringArray = result[1]
        
        Logger.info(jsonStringArray)
        
        guard let jsonData = jsonStringArray.data(using: .utf8) else {
            throw PubkyClientError.invalidResult
        }
        
        return try JSONDecoder().decode([String].self, from: jsonData)
    }
    
    func getC(url: String) async throws -> String {
        let result = get(url: url)
        try validateResult(result)
        return result[1]
    }
    
//    func deleteC(publicKey: String, url: String) async throws {
//        let result = delete
//    }
    
    static func chatStoreUrl(publicKey: String, chatId: String? = nil, messageId: String? = nil) -> String {
        var url = "pubky://\(publicKey)/pub/pubme.chat"
        if let chatId = chatId {
            url += "/\(chatId)"
        }
        
        if let messageId = messageId {
            url += "/\(messageId)"
        }
        
        return url
    }
}

func testPubkyClient() {
    Task {
        do {
            let chatId = "chat-1"
            Logger.test("Generating keys")
            let keypair = try await PubkyClient.shared.generateKeyPair()
            Logger.test(keypair)
            
            print("Signing up")
            try await PubkyClient.shared.signup(secretKey: keypair.secret_key, homeServerPublicKey: Env.defaultHomeServer)

            print("Put")
            try await PubkyClient.shared.putC(
                url: PubkyClient.chatStoreUrl(publicKey: keypair.public_key, chatId: chatId, messageId: "message-1"),
                body: Message.initNewSendMessage("Hello this message was sent!", ownPublicKey: keypair.public_key).toString()
            )
            
            try await PubkyClient.shared.putC(
                url: PubkyClient.chatStoreUrl(publicKey: keypair.public_key, chatId: chatId, messageId: "message-2"),
                body: Message.initNewSendMessage("Hello me again", ownPublicKey: keypair.public_key).toString()
            )

            print("List")
            let list = try await PubkyClient.shared.listC(url: PubkyClient.chatStoreUrl(publicKey: keypair.public_key))
            print("List (\(list.count)):")
            for url in list {
                let messageStr = try await PubkyClient.shared.getC(url: url)
                let message = try Message.initFromString(messageStr)
                print("Fetched message: " + message.body.text)
            }

//            print("Delete")
//            try await PubkyClient.shared.delete(
//                publicKey: keypair.public_key,
//                url: PubkyClient.chatStoreUrl(publicKey: keypair.public_key, chatId: chatId, messageId: "message-1")
//            )
        } catch {
            Logger.error(error)
        }
    }
}
