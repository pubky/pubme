//
//  ContentView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/01.
//

import SwiftUI

let client = PubkyClient()

struct ContentView: View {
    @State private var publicKey: String = "pk:7fmjpcuuzf54hw18bsgi3zihzyh4awseeuq5tmojefaezjbd64cy"
    @State var record: String? = nil
    @State var isResolving = false
    @State var milliseconds: UInt64? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Text("Public Key:")
                TextField("Enter text", text: $publicKey)
                
                Button("Resolve") {
                    record = nil
                    milliseconds = nil
                    isResolving = true
                    let startTime = DispatchTime.now().uptimeNanoseconds
                    
                    Task {
                        do {
                            let res = try client.pkarrResolve(publicKey: publicKey)
                            
                            DispatchQueue.main.async {
                                self.record =  res
                                isResolving = false
                                milliseconds = (DispatchTime.now().uptimeNanoseconds - startTime)/1000000
                            }
                        } catch {
                            self.record = "ERROR FROM RUST: \(error.localizedDescription)"
                            DispatchQueue.main.async {
                                isResolving = false
                            }
                        }
                    }
                }
                .disabled(isResolving)
                
                if isResolving {
                    ProgressView()
                }
                
                if let milliseconds {
                    Text("Resolved in \(milliseconds)ms")
                }
                
                if let record {
                    Text(record)
                        .font(.caption)
                }
            }
            .navigationTitle("Pkarr")
        }
        .onAppear {
            testPubkyClientProxy()
        }
    }
}

#Preview {
    ContentView()
}
