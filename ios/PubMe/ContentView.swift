//
//  ContentView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(sayHi())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
