//
//  MyPubkyView.swift
//  PubMe
//
//  Created by Jason van den Berg on 2024/08/06.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MyPubkyView: View {
    let publicKey: String
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @State var isCopied = false
    
    var body: some View {
        VStack {
            Text("Share your public key with your friends")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            if let qrImage = generateQRCode(from: publicKey) {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 200, height: 200)
            } else {
                Text("Failed to generate QR code")
            }
            
            ZStack {
                Text(publicKey)
                    .font(.caption2)
                    .padding()
                    .opacity(isCopied ? 0 : 1)
                
                Text("Copied!")
                    .font(.caption)
                    .opacity(isCopied ? 1 : 0)
            }
            
            Spacer()
        }
        .onTapGesture {
            UIPasteboard.general.string = publicKey
            withAnimation {
                isCopied = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    isCopied = false
                }
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}

#Preview {
    MyPubkyView(publicKey: "8pinxxgqs41n4aididenw5apqp1urfmzdztr8jt4abrkdn435ewo")
}
