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
    
    @AppStorage("keypointRadius") private var keypointRadius: Double = 5
    
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
                .fill(colorFor(node: node))
            
            if annotationController.selection == node {
                Circle()
                    .stroke(lineWidth: 2)
                    .fill(Color.white)
            }
        }
        .frame(width: CGFloat(keypointRadius) * 2, height: CGFloat(keypointRadius) * 2)
        .offset(
            x: CGFloat(node.value.x) / imageSize.width * imageViewSize.width - CGFloat(keypointRadius),
            y: CGFloat(node.value.y) / imageSize.height * imageViewSize.height - CGFloat(keypointRadius))
        .onTapGesture {
            annotationController.selection = node
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
            imageSize: CGSize(width: 2048, height: 2448)
        )
        .frame(width: 400, height: 600)
        .environmentObject(Self.controller)
    }
}
