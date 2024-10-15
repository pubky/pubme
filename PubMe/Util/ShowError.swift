//
//  ShowError.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI

private struct ShowErrorMessage: ViewModifier {
    @Binding var message: String

    @State private var showError = false

    func body(content: Content) -> some View {
        content
            .alert(message, isPresented: $showError) {
                Button("OK", role: .cancel) {}
            }
            .onAppear {
                showError = message.trimmingCharacters(in: .whitespacesAndNewlines) != ""
            }
            .onChange(of: message) { _ in
                showError = message.trimmingCharacters(in: .whitespacesAndNewlines) != ""
            }
            .onChange(of: showError) { _ in
                if !showError {
                    message = ""
                }
            }
    }
}

extension View {
    func showError(_ message: Binding<String>) -> some View {
        modifier(ShowErrorMessage(message: message))
    }
}

struct ShowError_Previews: PreviewProvider {
    @State static var errorMessage = "Hey I'm an error"
    static var previews: some View {
        VStack {
            Button("Show error") {
                errorMessage = "Heyo"
            }
            Text("errorMessage: \(errorMessage)")
        }
        .showError($errorMessage)
    }
}
