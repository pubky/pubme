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
        let keypairData = try await postRequest("generate-key-pair")
        
        return try JSONDecoder().decode(Keypair.self, from: keypairData)
    }
    
    func signup(secretKey: String) async throws {
        let _ = try await postRequest("signup", [
            "secretKey": secretKey,
            "homeServerPublicKey": homeServerPublicKey
        ])
    }
    
    func put(url: String, data: Data) async throws {
        
    }
    
    func list() async throws -> [String] {
        return []
    }
    
    func get(url: String) async throws -> Data {
        return Data()
    }
    
    func delete(url: String) async throws {
        
    }
}

enum PubkyClientProxyError: Error {
    case invalidResponse
}

extension PubkyClientProxy {
    fileprivate func postRequest(_ action: String, _ params: [String: String] = [:]) async throws -> Data {
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
}

func testPubkyClientProxy() {
    Task {
        do {
            print("Generating keys")
            let keypair = try await PubkyClientProxy.shared.generateKeyPair()
            print(keypair)
            
            print("Signing up")
            try await PubkyClientProxy.shared.signup(secretKey: keypair.secretKey)
            
        } catch {
            print("ERROR:")
            print(error.localizedDescription)
        }
    }
}
