//
//  PubkyClientProxy.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/05.
//

import Foundation

let proxyServer = "http://localhost:3000";
let homeServerPublicKey = "8pinxxgqs41n4aididenw5apqp1urfmzdztr8jt4abrkdn435ewo";

struct Keypair: Codable {
    let secretKey: String
    let publicKey: String
}



class PubkyClientProxy {
    static let shared = PubkyClientProxy()
    private init() {}
    
    func generateKeyPair() async throws -> Keypair {
        let keypairData = try await Self.postRequest("generate-key-pair")
        
        return try JSONDecoder().decode(Keypair.self, from: keypairData)
    }
    
    func signup(secretKey: String) async throws {
        let _ = try await Self.postRequest("signup", [
            "secretKey": secretKey,
            "homeServerPublicKey": homeServerPublicKey
        ])
    }
    
    func put(publicKey: String, url: String, body: String) async throws {
        let _ = try await Self.postRequest("put", [
            "publicKey": publicKey,
            "url": url,
            "body": body
        ])
        
        print("PUT: \(url)")
    }
    
    //Lists all URLs
    func list(url: String) async throws -> [String] {
        print(url)
        let listJsonString = try await Self.getRequest("list", [
            "url": url,
        ])
        
        guard let list = try JSONSerialization.jsonObject(with: listJsonString, options: []) as? [String] else {
            throw PubkyClientProxyError.invalidJson
        }
        
        return list
    }
    
    func get(url: String) async throws -> Data {
        return try await Self.getRequest("get", [
            "url": url
        ])
    }
    
    func delete(publicKey: String, url: String) async throws {
        let _ = try await Self.postRequest("delete", [
            "publicKey": publicKey,
            "url": url
        ])
    }
}

enum PubkyClientProxyError: Error {
    case invalidResponse
    case invalidJson
}

extension PubkyClientProxy {
    static func postRequest(_ action: String, _ params: [String: String] = [:]) async throws -> Data {
        let url = URL(string: "\(proxyServer)/\(action)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PubkyClientProxyError.invalidResponse
        }
        
        return data
    }
    
    static func getRequest(_ action: String, _ params: [String: String] = [:]) async throws -> Data {
        var urlComponents = URLComponents(string: "\(proxyServer)/\(action)")!
        urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PubkyClientProxyError.invalidResponse
        }
        
        return data
    }
    
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

func testPubkyClientProxy() {
    Task {
        do {
            let chatId = "chat-1"
            print("Generating keys")
            let keypair = try await PubkyClientProxy.shared.generateKeyPair()
            print(keypair)
            
            print("Signing up")
            try await PubkyClientProxy.shared.signup(secretKey: keypair.secretKey)
            
            print("Put")
            try await PubkyClientProxy.shared.put(
                publicKey: keypair.publicKey,
                url: PubkyClientProxy.chatStoreUrl(publicKey: keypair.publicKey, chatId: chatId, messageId: "message-1"),
                body: Message.initNewSendMessage("Hello this message was sent!").toString()
            )
            
            print("List")
            let list = try await PubkyClientProxy.shared.list(url: PubkyClientProxy.chatStoreUrl(publicKey: keypair.publicKey))
            print("List (\(list.count)):")
            for url in list {
                let messageData = try await PubkyClientProxy.shared.get(url: url)
                let message = try Message.initFromString(String(data: messageData, encoding: .utf8)!)
                print("Fetched message: " + message.body.text)
            }
            
            print("Delete")
            try await PubkyClientProxy.shared.delete(
                publicKey: keypair.publicKey,
                url: PubkyClientProxy.chatStoreUrl(publicKey: keypair.publicKey, chatId: chatId, messageId: "message-1")
            )
        } catch {
            print("ERROR:")
            print(error.localizedDescription)
        }
    }
}
