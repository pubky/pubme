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
        NavigationView {
            Form {
                Section("Backend") {
                    Label("Home Server", systemImage: "house.fill")
                    TextField("Home Server", text: $viewModel.homeServerPublicKey)
                        .font(.footnote)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
