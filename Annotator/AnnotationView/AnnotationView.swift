//
//  AnnotationView.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import SwiftUI
import RealModule

struct AnnotationView: View {
    @EnvironmentObject private var imageStoreController: ImageStoreController
    @EnvironmentObject private var annotationController: AnnotationController
    
    @State private var imageViewSize: CGSize?
    @State private var imageSize: CGSize?
    
    var body: some View {
        Group {
            if let selection = imageStoreController.selection {
                ImageView(url: selection, imageSize: $imageSize)
                    .overlay(annotationView)
                    .readSize(onChange: { imageViewSize = $0 })
                    .gesture(clickGesture)
                
            } else {
                Text("Choose an image or open a folder.")
            }
        }
        .padding()
        .disabled(imageSize == nil || imageViewSize == nil)
        .onReceive(imageStoreController.$selection) { selection in
            if let selection = selection {
                annotationController.loadAnnotation(forImageUrl: selection)
            } else {
                annotationController.reset()
            }
        }
    }
    
    @ViewBuilder
    var annotationView: some View {
        if let imageViewSize = imageViewSize, let imageSize = imageSize {
            AnnotationTreeView(imageViewSize: imageViewSize, imageSize: imageSize)
        } else {
            Text("Cannot read image size.")
        }
    }
    
    var clickGesture: some Gesture {
        ClickGesture(count: 2)
            .onEnded { value in
                guard value.first != nil else { return }
                guard let startLocation = value.second?.startLocation else { return }
                guard let endLocation = value.second?.location else { return }
                guard ((startLocation.x-1)...(startLocation.x+1)).contains(endLocation.x),
                      ((startLocation.y-1)...(startLocation.y+1)).contains(endLocation.y) else { return }
                
                onDoubleClick(startLocation)
            }
    }
    
    func onDoubleClick(_ location: CGPoint) {
        guard let imageUrl = imageStoreController.selection,
              let imageSize = imageSize,
              let imageViewSize = imageViewSize else {
            return
        }
        
        let node = Node(Keypoint(
            name: "",
            x: Double(location.x / imageViewSize.width * imageSize.width),
            y: Double(location.y / imageViewSize.height * imageSize.height))
        )
         
        annotationController.addNode(node, imageUrl: imageUrl, imageSize: imageSize)
    }
}

struct AnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationView()
            .environmentObject(
                ImageStoreController(
                    folder: URL(string: "/Users/louislac/Downloads/Biomass/2021/p0215_0914")
                )
            )
            .environmentObject(AnnotationController())
            .frame(width: 800, height: 600)
    }
}
