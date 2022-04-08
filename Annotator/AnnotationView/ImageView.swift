//
//  ImageView.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import SwiftUI
import AppKit

struct ImageView: View {
    let url: URL
    @Binding var imageSize: CGSize?
    @State private var nsImage: NSImage?
    
    var body: some View {
        Group {
            if let nsImage = nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onAppear { imageSize = nsImage.size }
            }
        }
        .onAppear {
            nsImage = NSImage(contentsOf: url)
        }
        .onChange(of: url) { newValue in
            nsImage = NSImage(contentsOf: newValue)
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(url: URL(string: "/Users/louislac/Downloads/im_01516.jpg")!, imageSize: .constant(.zero))
    }
}
