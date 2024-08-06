//
//  SettingsView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = ViewModel.shared
    
    var body: some View {
        Form {
            Section("My public key") {
                MyPubkyView(publicKey: viewModel.myPublicKey)
                    .padding(.vertical)
            }
            
            Section("Backend") {
                Label("Home Server", systemImage: "house.fill")
                TextField("Home Server", text: $viewModel.homeServerPublicKey)
                    .font(.footnote)
            }
        }
    }
}

#Preview {
    SettingsView()
}
