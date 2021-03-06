//
//  AnnotationView.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import SwiftUI
import Numerics

struct AnnotationView: View {
    @EnvironmentObject private var imageStoreController: ImageStoreController
    @EnvironmentObject private var annotationController: AnnotationController
    
    // FIXME: - Maybe replace by a concrete Optional struct `ImageData`?
    @State private var imageViewSize: CGSize?
    @State private var imageSize: CGSize?
    
    @GestureState private var rectangle: CGRect?
    
    var body: some View {
        Group {
            if let selection = imageStoreController.selection {
                ImageView(url: selection, imageSize: $imageSize)
                    .aspectRatio(contentMode: .fit)
                    .overlay(overlaidView, alignment: .topLeading)
                    .readSize(onChange: { imageViewSize = $0 })
                    .gesture(tapGesture)
            } else {
                Text("Choose an image or open a folder")
            }
        }
        .padding()
        .onReceive(imageStoreController.$selection) { selection in
            if let selection = selection {
                tryLoadAnnotationFrom(imageUrl: selection)
            }
        }
        .disabled(imageSize == nil || imageViewSize == nil)
    }
    
    var overlaidView: some View {
        ZStack(alignment: .topLeading) {
            if let rectangle = rectangle {
                Rectangle()
                    .stroke(lineWidth: 2)
                    .fill(Color.gray)
                    .frame(width: rectangle.width, height: rectangle.height)
                    .offset(x: rectangle.minX, y: rectangle.minY)
            }
            
            if let imageSize = imageSize, let imageViewSize = imageViewSize {
                ForEach(annotationController.tree.reduce({ $0 })) { node in
                    viewFor(node: node, viewSize: imageViewSize, imageSize: imageSize)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .overlay(Text("Image size is not readable, cannot edit.")
                                .font(.headline)
                                .foregroundColor(.white))
            }
        }
    }
    
    func viewFor(node: KeypointNode, viewSize: CGSize , imageSize: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(node.children) { child in
                Path { path in
                    path.move(to: CGPoint(
                        x: CGFloat(node.value.x) / imageSize.width * viewSize.width,
                        y: CGFloat(node.value.y) / imageSize.height * viewSize.height)
                    )
                    path.addLine(to: CGPoint(
                        x: CGFloat(child.value.x) / imageSize.width * viewSize.width,
                        y: CGFloat(child.value.y) / imageSize.height * viewSize.height)
                    )
                }
                .stroke(lineWidth: 2)
                .foregroundColor(.red)
            }
            
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .offset(
                    x: CGFloat(node.value.x) / imageSize.width * viewSize.width - 5,
                    y: CGFloat(node.value.y) / imageSize.height * viewSize.height - 5)
                .overlay(Circle()
                            .stroke(lineWidth: 2)
                            .fill(annotationController.selection == node ? Color.white : .clear)
                            .frame(width: 10, height: 10)
                            .offset(
                                x: CGFloat(node.value.x) / imageSize.width * viewSize.width - 5,
                                y: CGFloat(node.value.y) / imageSize.height * viewSize.height - 5))
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            annotationController.selection = node
                        }
                )
        }
    }
    
    var tapGesture: some Gesture {
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
        guard let imageSize = imageSize, let imageViewSize = imageViewSize else {
            return
        }
        
        let node = Node(Keypoint(
            name: "test",
            x: Double(location.x / imageViewSize.width * imageSize.width),
            y: Double(location.y / imageViewSize.height * imageSize.height))
        )
         
        if let selection = annotationController.selection {
            selection.children.append(node)
            annotationController.selection = node
        } else if let root = annotationController.tree.root {
            root.children.append(node)
            annotationController.selection = node
        } else {
            annotationController.tree.root = node
            annotationController.selection = node
        }
        annotationController.objectWillChange.send()
        saveAnnotation()
    }
    
    func saveAnnotation() {
        DispatchQueue.global(qos: .background).async {
            guard let url = imageStoreController.selection, let imageSize = imageSize else { return }
            try? annotationController.save(url, imageSize: imageSize)
        }
    }
    
    func tryLoadAnnotationFrom(imageUrl: URL) {
        let url = imageUrl.deletingPathExtension().appendingPathExtension("json")
        try? annotationController.load(fileUrl: url)
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
