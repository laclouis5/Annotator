//
//  AnnotationTreeView.swift
//  Annotator
//
//  Created by Louis Lac on 06/03/2021.
//

import SwiftUI

struct AnnotationTreeView: View {
    @EnvironmentObject private var annotationController: AnnotationController
    
    @AppStorage("keypointRadius") private var radius: Double = 5
    @AppStorage("keypointOpacity") private var opacity: Double = 1/2
    
    let imageViewSize: CGSize
    let imageSize: CGSize
    let imageUrl: URL
    
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
                .fill(colorFor(node: node).opacity(opacity))
            
            if annotationController.selection === node {
                Circle()
                    .stroke(lineWidth: 1.5)
                    .fill(Color.white.opacity(opacity))
            }
        }
        .frame(width: CGFloat(radius) * 2, height: CGFloat(radius) * 2)
        .offset(
            x: CGFloat(node.value.x) / imageSize.width * imageViewSize.width - CGFloat(radius),
            y: CGFloat(node.value.y) / imageSize.height * imageViewSize.height - CGFloat(radius))
        .gesture(tapOrDragGesture(node: node))
        .contextMenu {
            Button("Remove") {
                annotationController.remove(node: node)
                annotationController.save(imageUrl, imageSize: imageSize)
            }
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
        .stroke(lineWidth: 3)
        .foregroundColor(colorForConnection(from: start, to: stop).opacity(opacity))
        .onClickGesture(count: 1) { location in
            let x = Double(location.x / imageViewSize.width * imageSize.width) - radius
            let y = Double(location.y / imageViewSize.height * imageSize.height) - radius
            annotationController.insert(keypoint: Keypoint(name: "", x: x, y: y), before: stop)
        }
    }
    
    func colorFor(node: KeypointNode) -> Color {
        if node === annotationController.tree.root {
            return .red
        } else if node.isLeaf {
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
                annotationController.move(node: node,
                    x: Double(value.location.x / imageViewSize.width * imageSize.width) - radius,
                    y: Double(value.location.y / imageViewSize.height * imageSize.height) - radius
                )
            }
            .exclusively(before: TapGesture())
            .onEnded { (value) in
                switch value {
                case .first(let value):
                    annotationController.move(node: node,
                        x: Double(value.location.x / imageViewSize.width * imageSize.width) - radius,
                        y: Double(value.location.y / imageViewSize.height * imageSize.height) - radius)
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
