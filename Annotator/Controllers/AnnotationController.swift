//
//  AnnotationController.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import Foundation
import Combine

final class AnnotationController: ObservableObject {
    /// The current tree annotation.
    private var tree: KeypointTree
    
    /// The tree nodes in an array for use in SwiftUI List views.
    @Published private(set) var nodes: [KeypointNode]
    
    /// The selected node.
    @Published var selection: KeypointNode?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(tree: KeypointTree = .init()) {
        self.tree = tree
        self.nodes = tree.reduce { $0 }
    }
    
    /// Add a node to the curent selected node or to the root of the tree.
    /// This action saves the annotation to disk.
    /// - Parameters:
    ///   - node: The KeypointNode to add.
    ///   - imageUrl: The URL of the image being annotated.
    ///   - imageSize: The size of the image being annotated.
    func add(node: KeypointNode, imageUrl: URL, imageSize: CGSize) {
        if let selection = selection {
            selection.addChild(node)
            self.selection = node
        } else if let root = tree.root {
            root.addChild(node)
            self.selection = node
        } else {
            tree.root = node
            selection = node
        }
        
        nodes.append(node)
    }
    
    /// Add a node to the curent selected node or to the root of the tree.
    /// This action saves the annotation to disk.
    /// - Parameters:
    ///   - keypoint: The keypoint to add.
    ///   - imageUrl: The URL of the image being annotated.
    ///   - imageSize: The size of the image being annotated.
    func add(keypoint: Keypoint<Double>, imageUrl: URL, imageSize: CGSize) {
        let node = KeypointNode(keypoint)
        add(node: node, imageUrl: imageUrl, imageSize: imageSize)
    }
    
    /// Remove a node from the annotation tree. The node children are assigned to
    /// the node parent if there is one. If not, the node cannot be removed as
    /// it is the root node and the removal is not performed. This methods does not
    /// checks if the node belongs to the tree before removal, make sure it is.
    /// - Parameter node: The node to remove.
    func remove(node: KeypointNode) {
        if let parent = node.parent {
            parent.removeChild(node)
            parent.addChildren(node.children)
            selection = parent
        } else if node.children.isEmpty {
            selection = nil
            tree.root = nil
        } else if node.children.count == 1 {
            tree.root = node.children.first!
            selection = tree.root
        }
        
        nodes.remove(at: nodes.firstIndex { node === $0 }!)
    }
    
    /// Move a node position.
    /// - Parameters:
    ///   - node: The node to move.
    ///   - x: The new horizontal position in the image coordinate system.
    ///   - y: The new vertical position in the image coordinate system.
    func move(node: KeypointNode, x: Double, y: Double) {
        selection = node
        node.value.x = x
        node.value.y = y
    }
    
    /// Insert a new node between two given nodes.
    /// - Parameters:
    ///   - newNode: The node to insert.
    ///   - child: The node before which the new node will be inserted.
    func insert(node: KeypointNode, before child: KeypointNode) {
        child.parent?.insert(node, before: child)
        selection = node
        
        nodes.append(node)
    }
    
    /// Insert a new node between two given nodes.
    /// - Parameters:
    ///   - keypoint: The keypoint to insert.
    ///   - child: The node before which the new node will be inserted.
    func insert(keypoint: Keypoint<Double>, before child: KeypointNode) {
        let node = Node(keypoint)
        insert(node: node, before: child)
    }
    
    /// Saves the current tree to the specified URL in JSON format.
    /// - Parameters:
    ///   - imageUrl: The URL of the image being annotated.
    ///   - imageSize: The size of the image being annotated.
    func save(_ imageUrl: URL, imageSize: CGSize) {
        do {
            let size = Size(cgSize: imageSize)
            let annotation = AnnotationTree(imageUrl: imageUrl, tree: tree, imageSize: size)
            let data = try encoder.encode(annotation)
            let saveUrl = imageUrl.deletingPathExtension().appendingPathExtension("json")
            try data.write(to: saveUrl)
        } catch {
            print("Error while writing annotation")
        }
    }
    
    /// Load annotation from disk.
    /// - Parameter url: The annotation URL on disk.
    func loadAnnotation(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let annotation = try decoder.decode(AnnotationTree.self, from: data)
            tree = annotation.tree
            nodes = tree.reduce { $0 }
            selection = tree.root
        } catch {
            reset()
        }
    }
    
    /// Load annotation from disk.
    /// - Parameter imageUrl: The image URL on disk. The annotation should have the
    /// save name with a `.json` extension.
    func loadAnnotation(forImageUrl imageUrl: URL) {
        let url = imageUrl.deletingPathExtension().appendingPathExtension("json")
        loadAnnotation(url: url)
    }
    
    /// Reset both the annotation tree and the selected node to `nil`.
    func reset() {
        tree = .init()
        nodes = []
        selection = nil
    }
}
