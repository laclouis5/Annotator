//
//  AnnotationTreeView.swift
//  Annotator
//
//  Created by Louis Lac on 06/03/2021.
//

import SwiftUI

struct AnnotationTreeView: View {
    @EnvironmentObject private var annotationController: AnnotationController
    
    let imageViewSize: CGSize
    let imageSize: CGSize
    let imageUrl: URL
    
    @AppStorage("keypointRadius") private var keypointRadius: Double = 6
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { _ in
                ForEach(annotationController.tree.reduce({ $0 })) { node in
                    ForEach(node.children) { child in
                        connectionView(start: node, stop: child)
                    }
                    
                    keypointView(node: node)
                }
            }
        }
    }
    
    func keypointView(node: KeypointNode) -> some View {
        ZStack {
            Circle()
                .fill(colorFor(node: node).opacity(2/3))
            
            if annotationController.selection == node {
                Circle()
                    .stroke(lineWidth: 1.5)
                    .fill(Color.white.opacity(2/3))
            }
        }
        .frame(width: CGFloat(keypointRadius) * 2, height: CGFloat(keypointRadius) * 2)
        .offset(
            x: CGFloat(node.value.x) / imageSize.width * imageViewSize.width - CGFloat(keypointRadius),
            y: CGFloat(node.value.y) / imageSize.height * imageViewSize.height - CGFloat(keypointRadius))
        .gesture(tapOrDragGesture(node: node))
        .contextMenu {
            Button("Remove", action: { annotationController.remove(node) })
        }
    }
    
    func connectionView(start: KeypointNode, stop: KeypointNode) -> some View {
        Path { path in
            path.move(to: CGPoint(
                x: CGFloat(start.value.x) / imageSize.width * imageViewSize.width,
                y: CGFloat(start.value.y) / imageSize.height * imageViewSize.height)
            )
            path.addLine(to: CGPoint(
                x: CGFloat(stop.value.x) / imageSize.width * imageViewSize.width,
                y: CGFloat(stop.value.y) / imageSize.height * imageViewSize.height)
            )
        }
        .stroke(lineWidth: 2)
        .foregroundColor(colorForConnection(from: start, to: stop))
    }
    
    func colorFor(node: KeypointNode) -> Color {
        if node === annotationController.tree.root {
            return .red
        } else if node.children.isEmpty {
            return .green
        } else {
            return .orange
        }
    }
    
    func colorForConnection(from start: KeypointNode, to stop: KeypointNode) -> Color {
        colorFor(node: start)
    }
    
    func tapOrDragGesture(node: KeypointNode) -> some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                annotationController.moveNode(node,
                    x: Double(value.location.x / imageViewSize.width * imageSize.width) - keypointRadius,
                    y: Double(value.location.y / imageViewSize.height * imageSize.height) - keypointRadius
                )
            }
            .exclusively(before: TapGesture())
            .onEnded { (value) in
                switch value {
                case .first(let value):
                    annotationController.moveNode(node,
                        x: Double(value.location.x / imageViewSize.width * imageSize.width) - keypointRadius,
                        y: Double(value.location.y / imageViewSize.height * imageSize.height) - keypointRadius)
                    annotationController.save(imageUrl, imageSize: imageSize)
                case .second:
                    annotationController.selection = node
                }
            }
    }
}

struct TreeView_Previews: PreviewProvider {
    static let controller = AnnotationController(
        tree: KeypointTree(
            root: KeypointNode(
                Keypoint(name: "root", x: 0, y: 0),
                children: [/*
                    KeypointNode(Keypoint(name: "first", x: 100, y: 100), children: [])
                */]
            )
        )
    )
    
    static var previews: some View {
        AnnotationTreeView(
            imageViewSize: CGSize(width: 800, height: 1000),
            imageSize: CGSize(width: 2048, height: 2448),
            imageUrl: URL(string: "/tmp/image.jpg")!
        )
        .frame(width: 400, height: 600)
        .environmentObject(Self.controller)
    }
}
