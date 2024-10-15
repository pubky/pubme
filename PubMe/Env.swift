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
    
    static let defaultHomeServer = "pubky://53o4xyymy815yp3kwttswsoub4od5wsddznjcz46tx65t31cbxro"
    
    static let tempDefaultFriendPublicKeys = [
        ""
    ]
}
