//
//  ContentView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/01.
//

import SwiftUI

// let client = PubkyClient()

struct ContentView: View {
    @StateObject private var viewModel = ViewModel.shared

    var body: some View {
        NavigationView {
            if viewModel.keypairExists == nil {
                ProgressView()
            } else if viewModel.keypairExists == true {
                ChatListView()
            } else {
                OnboardingView()
            }
        }
        .onChange(of: viewModel.keypairExists) { _ in
            Logger.info("keypair exists state changed: \(viewModel.keypairExists?.description ?? "nil")")
        }
        .onAppear {
            Task {
                try await viewModel.setKeypairExistsState()
            }
        }
    }
}

#Preview {
    ContentView()
}
