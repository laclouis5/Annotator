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
    
    init(url: URL) {
        self.url = url
    }
    
    init?(path: String) {
        guard let url = URL(string: path) else {
            return nil
        }
        self.init(url: url)
    }
    
    var image: NSImage {
        NSImage(byReferencing: url)
    }
    
    var imageSize: CGSize? {
        // with CGImageSource we avoid loading the whole image into memory
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        
        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
            return nil
        }
        
        if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
           let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
            return CGSize(width: width, height: height)
        } else {
            return nil
        }
    }
    
    var body: some View {
        Image(nsImage: image)
            .resizable()
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(url: URL(string: "/Users/louislac/Downloads/im_01516.jpg")!)
    }
}
