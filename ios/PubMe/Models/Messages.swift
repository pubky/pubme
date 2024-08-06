//
//  Messages.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct ChatGroup: Identifiable {
    var id = UUID().uuidString
    var publicKeys: [String]
}

struct MessageBody: Codable {
    let text: String
    let timestamp: Date
}

struct Message: Codable, Identifiable {
    static func initNewSendMessage(_ text: String) -> Message {
        return Message(id: UUID().uuidString, body: MessageBody(text: text, timestamp: Date()))
    }
    
    static func initFromString(_ jsonString: String) throws -> Message {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = jsonString.data(using: .utf8) else {
            throw PubkyClientProxyError.invalidJson
        }
        return try decoder.decode(Message.self, from: data)
    }
    
    func toString() throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        } else {
            throw PubkyClientProxyError.invalidJson
        }
    }
    
    let id: String
    let body: MessageBody
}
