//
//  Env.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import Foundation

enum Env {
    static let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    static let isUnitTest = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    
    #if targetEnvironment(simulator)
        static let isSim = true
    #else
        static let isSim = false
    #endif
    
    #if DEBUG
        static let isDebug = true
    #else
        static let isDebug = false
    #endif
    
    static let defaultHomeServer = "pubky://i7mfcaj8nkujwaec3uzoo3n8tm1yrpmgskgho4enmtjyf5kwq6ky"
    static let tempClientProxyServer = "http://localhost:3000"
    
    static let tempDefaultFriendPublicKeys = [
        ""
    ]
}