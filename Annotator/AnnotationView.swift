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
    
    @State private var imageViewSize: CGSize = .zero
    
    @GestureState private var rectangle: CGRect = .null
    
    var body: some View {
        Group {
            if let selection = store.selection {
                ImageView(url: selection)
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
    }
    
    var overlaidView: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .stroke(lineWidth: 2)
                .fill(Color.gray)
                .frame(width: rectangle.width, height: rectangle.height)
                .offset(x: rectangle.minX, y: rectangle.minY)
            
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
                        width: CGFloat(box.width),
                        height: CGFloat(box.height)
                    )
                    .offset(
                        x: CGFloat(box.xMin),
                        y: CGFloat(box.yMin)
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
        let box = Box<Double>(origin: value.startLocation, size: value.translation)
        annotation.objects.append(Object<Double>(name: "text", box: box))
    }
}

struct AnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationView()
    }
}
