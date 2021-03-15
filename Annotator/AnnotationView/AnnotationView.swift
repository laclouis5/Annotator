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
    @EnvironmentObject private var labelsController: LabelsController
    @EnvironmentObject private var imagePreference: ImageScalePreference
    @StateObject private var annotationController = AnnotationController()
    @State private var imageViewSize: CGSize?
    @State private var imageSize: CGSize?
    
    var body: some View {
        Group {
            if let selection = imageStoreController.selection {
                GeometryReader { geo in
                    ScrollView([.horizontal, .vertical]) {
                        ImageView(url: selection, imageSize: $imageSize)
                            .overlay(annotationView)
                            .readSize(onChange: { imageViewSize = $0 })
                            .onClickGesture(count: 2, perform: addNewNode)
                            .frame(
                                width: geo.size.width * imagePreference.imageScale,
                                height: geo.size.height * imagePreference.imageScale)
                    }
                }
            } else {
                Text("Choose an image or open a folder.")
            }
        }
        .padding()
        .disabled(imageSize == nil || imageViewSize == nil)
        .onReceive(imageStoreController.$selection, perform: loadAnnotation(url:))
        .environmentObject(annotationController)
    }
    
    @ViewBuilder
    var annotationView: some View {
        if let imageViewSize = imageViewSize, let imageSize = imageSize, let imageUrl = imageStoreController.selection {
            AnnotationTreeView(imageViewSize: imageViewSize, imageSize: imageSize, imageUrl: imageUrl)
        } else {
            Text("Cannot read image size.")
        }
    }
    
    func addNewNode(at location: CGPoint) {
        guard let imageUrl = imageStoreController.selection,
              let imageSize = imageSize,
              let imageViewSize = imageViewSize else {
            return
        }
        
        let keypoint = Keypoint(
            name: labelsController.selection,
            x: Double(location.x / imageViewSize.width * imageSize.width),
            y: Double(location.y / imageViewSize.height * imageSize.height)
        )
         
        annotationController.add(keypoint: keypoint, imageUrl: imageUrl, imageSize: imageSize)
        annotationController.save(imageUrl, imageSize: imageSize)
    }
    
    func loadAnnotation(url: URL?) {
        if let url = url {
            annotationController.loadAnnotation(forImageUrl: url)
        } else {
            annotationController.reset()
        }
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
