//
//  Onboarding.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct OnboardingView: View {
    @State var isResolving = false
    @State var isCreating = false
    @State var resolved = ""
    @State var errorMessage = ""
    
    @StateObject var viewModel = ViewModel.shared
    
    var body: some View {
        VStack {
            Text("Welcome to PubMe!")
                .font(.title)
                .padding()
            Spacer()
            VStack {
                Label("Home Server", systemImage: "house.fill")
                TextField("Home Server", text: $viewModel.homeServerPublicKey)
                    .font(.footnote)
                    .onChange(of: viewModel.homeServerPublicKey) { _ in
                        resolved = ""
                    }
                
                if viewModel.homeServerPublicKey != Env.defaultHomeServer {
                    Button(action: {
                        viewModel.homeServerPublicKey = Env.defaultHomeServer
                    }, label: {
                        Label("Reset to Default", systemImage: "arrow.counterclockwise")
                    })
                }
                
                if !resolved.isEmpty {
                    Text(resolved)
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .padding()
            
            Spacer()
            
            if isCreating || isResolving {
                loader
            } else if resolved.isEmpty {
                resolveButton
            } else {
                createButton
            }
        }
        .showError($errorMessage)
    }
    
    @ViewBuilder
    var resolveButton: some View {
        Button(action: {
            isResolving = true
            
            // Place on random background queue
            DispatchQueue.global().async {
                var r = ""
                do {
                    r = try (resolve(publicKey: viewModel.homeServerPublicKey)).joined(separator: "\n")
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                        isResolving = false
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    if r.contains("Failed") || r.contains("Invalid") {
                        errorMessage = r
                    } else {
                        resolved = r
                    }
                    isResolving = false
                }
            }
        }, label: {
            Label("Resolve Home Server", systemImage: "key.icloud")
        })
        .padding()
    }
    
    @ViewBuilder
    var createButton: some View {
        Button(action: {
            Task { @MainActor in
                isCreating = true
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
    
    @ViewBuilder
    var loader: some View {
        if isResolving {
            ProgressView("Resolving Home Server...")
        } else if isCreating {
            ProgressView("Creating Keypair...")
        }
    }
}

#Preview {
    OnboardingView()
}
