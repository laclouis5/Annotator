//
//  ImageScalePreference.swift
//  Annotator
//
//  Created by Louis Lac on 12/03/2021.
//

import SwiftUI

final class ImageScalePreference: ObservableObject {
    @Published private(set) var imageScale: CGFloat = 1
    
    func increaseImageScale() {
        imageScale = min(max(imageScale * 2, 1.0), 5)
    }
    
    func decreaseImageScale() {
        imageScale = min(max(imageScale / 2, 1.0), 5)
    }
    
    func resetImageScale() {
        imageScale = 1
    }
}
