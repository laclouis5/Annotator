//
//  AnnotationView.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import SwiftUI

struct AnnotationView: View {
    @EnvironmentObject private var store: ImageStoreController
    @EnvironmentObject private var annotation: AnnotationController
    
    // FIXME: - Maybe replace by a concrete Optional struct `ImageData`?
    @State private var imageViewSize: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    
    @GestureState private var rectangle: CGRect?
    
    var body: some View {
        Group {
            if let selection = store.selection {
                ImageView(url: selection, imageSize: $imageSize)
                    .aspectRatio(contentMode: .fit)
                    .overlay(overlaidView, alignment: .topLeading)
                    .readSize(onChange: { imageViewSize = $0 })
                    .onTapWithLocation(count: 2, onDoubleClick)
                    .gesture(dragGesture)
            } else {
                Text("Choose an image or open a folder")
            }
        }
        .padding()
        .onReceive(store.$selection) { selection in
            if let selection = selection {
                tryLoadAnnotationFrom(imageUrl: selection)
            }
        }
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
            
            objectsView
        }
    }
    
    var objectsView: some View {
        ForEach(annotation.objects, id: \.self) { object in
            if let box = object.box {
                Rectangle()
                    .stroke(lineWidth: 2)
                    .fill(Color.white)
                    .frame(
                        width: CGFloat(box.width) / imageSize.width * imageViewSize.width,
                        height: CGFloat(box.height) / imageSize.height * imageViewSize.height
                    )
                    .offset(
                        x: CGFloat(box.xMin) / imageSize.width * imageViewSize.width,
                        y: CGFloat(box.yMin) / imageSize.height * imageViewSize.height
                    )
            }
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
            .updating($rectangle) { (value, state, _) in
                state = CGRect(origin: value.startLocation, size: value.translation)
            }
            .onEnded(onDragGestureEnded)
    }
    
    func onDoubleClick(_ value: CGPoint) { }
    
    func onDragGestureEnded(_ value: DragGesture.Value) {
        let origin = CGPoint(
            x: value.startLocation.x / imageViewSize.width * imageSize.width,
            y: value.startLocation.y / imageViewSize.height * imageSize.height
        )
        let size = CGSize(
            width: value.translation.width / imageViewSize.width * imageSize.width,
            height: value.translation.height / imageViewSize.height * imageSize.height
        )
        let box = Box<Double>(origin: origin, size: size)
        
        // FIXME: Should be encapsulated in the controller
        annotation.objects.append(Object<Double>(name: "text", box: box))
        saveAnnotation()
    }
    
    func saveAnnotation() {
        DispatchQueue.global(qos: .background).async {
            guard let url = store.selection else { return }
            try? annotation.save(url, imageSize: imageSize)
        }
    }
    
    func tryLoadAnnotationFrom(imageUrl: URL) {
        let url = imageUrl.deletingPathExtension().appendingPathExtension("json")
        annotation.loadAnnotationFor(imageUrl: url)
    }
}

struct AnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationView()
    }
}
