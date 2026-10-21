//
//  PubMeApp.swift
//  PubMe
//
//  Created by Jasonvdb on 2024/08/01.
//

import SwiftUI

@main
struct PubMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
//            VStack {
//                Text("Hello, world!")
//                    .padding()
//            }
                .onAppear {
                    testPubkyClient()
                }
        }
    }
}
