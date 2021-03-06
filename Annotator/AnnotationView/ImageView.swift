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
    
    var nsImage: NSImage {
        NSImage(byReferencing: url)
    }
    
    var body: some View {
        Image(nsImage: nsImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onAppear { imageSize = size }
    }
    
    var size: CGSize? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
            return nil
        }
        
        if var width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
           var height = properties[kCGImagePropertyPixelHeight] as? CGFloat,
           let orientation = properties[kCGImagePropertyOrientation] as? Int {
            if orientation == 6 || orientation == 8 {
                swap(&width, &height)
            }
            return CGSize(width: width, height: height)
        } else {
            return nil
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(url: URL(string: "/Users/louislac/Downloads/im_01516.jpg")!, imageSize: .constant(.zero))
    }
}
