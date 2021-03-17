//
//  AnnotationTreeView.swift
//  Annotator
//
//  Created by Louis Lac on 06/03/2021.
//

import SwiftUI

struct AnnotationTreeView: View {
    @EnvironmentObject private var annotationController: AnnotationController
    @EnvironmentObject private var labelsController: LabelsController
    @AppStorage("keypointRadius") private var radius: Double = 5
    @AppStorage("keypointOpacity") private var opacity: Double = 1/2
    
    let imageViewSize: CGSize
    let imageSize: CGSize
    let imageUrl: URL
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { _ in
                ForEach(annotationController.nodes) { node in
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
                .fill(colorForNode(node).opacity(opacity))

            Circle()
                .stroke(Color.black.opacity(opacity), lineWidth: 1.5)

            if annotationController.selection === node {
                Circle()
                    .stroke(Color.white, lineWidth: 1.5)
            }
        }
        .frame(width: CGFloat(radius) * 2, height: CGFloat(radius) * 2)
        .offset(
            x: CGFloat(node.value.x) / imageSize.width * imageViewSize.width - CGFloat(radius),
            y: CGFloat(node.value.y) / imageSize.height * imageViewSize.height - CGFloat(radius))
        .gesture(tapOrDragGesture(node: node))
        .contextMenu { menuItems(node: node) }
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
        .stroke(lineWidth: 4)
        .foregroundColor(colorForConnection(from: start, to: stop).opacity(opacity))
        .onClickGesture(count: 1) { location in
            let x = Double(location.x / imageViewSize.width * imageSize.width)
            let y = Double(location.y / imageViewSize.height * imageSize.height)
            let keypoint = Keypoint(name: labelsController.selection, x: x, y: y)
            annotationController.insert(keypoint: keypoint, before: stop)
        }
    }
    
    func colorForNode(_ node: KeypointNode) -> Color {
        if node.isRoot {
            return .red
        } else if node.value.name != nil {
            return .blue
        } else if node.isLeaf {
            return .green
        } else {
            return .orange
        }
    }
    
    func colorForConnection(from start: KeypointNode, to stop: KeypointNode) -> Color {
        colorForNode(stop)
    }
    
    /// Workaround because did not declared KeypointNode as `ObservableObject`.
    /// Should create view models for this instead.
    func nameBinding(for node: KeypointNode) -> Binding<String?> {
        Binding {
            node.value.name
        } set: {
            annotationController.objectWillChange.send()
            node.value.name = $0
            annotationController.save(imageUrl, imageSize: imageSize)
        }
    }
    
    @ViewBuilder
    func menuItems(node: KeypointNode) -> some View {
        Button(action: {
            annotationController.remove(node: node)
            annotationController.save(imageUrl, imageSize: imageSize)
        }) {
            Label("Remove", systemSymbol: .trash)
        }
        
        Picker(selection: nameBinding(for: node), label: Label("Label", systemSymbol: .pencil)) {
            Text("None").tag(String?.none)

            ForEach(labelsController.labels, id: \.self) { label in
                Text(label).tag(String?.some(label))
            }
        }
    }
    
    func tapOrDragGesture(node: KeypointNode) -> some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                annotationController.move(node: node,
                    x: Double(value.location.x / imageViewSize.width * imageSize.width) ,
                    y: Double(value.location.y / imageViewSize.height * imageSize.height)
                )
            }
            .exclusively(before: TapGesture())
            .onEnded { (value) in
                switch value {
                case .first(let value):
                    annotationController.move(node: node,
                        x: Double(value.location.x / imageViewSize.width * imageSize.width),
                        y: Double(value.location.y / imageViewSize.height * imageSize.height))
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
