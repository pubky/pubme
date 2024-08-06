//
//  Onboarding.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct Onboarding: View {
    @State var isCreating = false
    @State var errorMessage = ""
    
    var body: some View {
        Text("Welcome to PubMe!")
            .font(.title)
            .padding()
        
        if isCreating {
            ProgressView("Creating Keypair...")
        } else {
            Button(action: {
                isCreating = true
                Task { @MainActor in
                    do {
                        try await ViewModel.shared.createKeyPair()
                    } catch {
                        errorMessage = error.localizedDescription
                        isCreating = false
                    }
                }
            }, label: {
                Label("Create Keypair", systemImage: "key.fill")
            })
            .padding()
        }
    }
}

#Preview {
    Onboarding()
}
