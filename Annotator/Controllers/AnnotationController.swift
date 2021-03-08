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
    @Published private(set) var tree: KeypointTree
    
    /// The selected node.
    @Published var selection: KeypointNode?
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    private let decoder = JSONDecoder()
    
    init(tree: KeypointTree = .init()) {
        self.tree = tree
    }
    
    /// Add a node to the curent selected node or to the root of the tree.
    /// This action triggers `objectWillChange.send()` and saves the annotation to disk.
    /// - Parameters:
    ///   - node: The KeypointNode to add.
    ///   - imageUrl: The URL of the image being annotated.
    ///   - imageSize: The size of the image being annotated.
    func addNode(_ node: KeypointNode, imageUrl: URL, imageSize: CGSize) {
        objectWillChange.send()
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
    }
    
    /// Remove a node from the annotation tree. The node children are assigned to
    /// the node parent if there is one. If not, the node cannot be removed as
    /// it is the root node and the removal is not performed. This methods does not
    /// checks if the node belongs to the tree before removal, make sure it is.
    /// - Parameter node: The node to remove.
    func removeNode(_ node: KeypointNode?) {
        guard let node = node else { return }
        objectWillChange.send()
        node.parent?.removeChild(node)
        node.parent?.addChildren(node.children)
    }
    
    /// Move a node position and trigger a `objectWillChange.send()`.
    /// - Parameters:
    ///   - node: The node to move.
    ///   - x: The new horizontal position in the image coordinate system.
    ///   - y: The new vertical position in the image coordinate system.
    func moveNode(_ node: KeypointNode, x: Double, y: Double) {
        objectWillChange.send()
        node.value.x = x
        node.value.y = y
    }
    
    /// Insert a new node between two given nodes.
    /// - Parameters:
    ///   - newNode: The node to insert.
    ///   - node: The node after which the new node will be inserted.
    ///   - child: The node before which the new node will be inserted. This node must be
    ///   a child of `node`.
    func insertNode(_ newNode: KeypointNode, to node: KeypointNode, before child: KeypointNode) {
        objectWillChange.send()
        node.insert(newNode, before: child)
    }
    
    /// Saves the current tree to the specified URL in JSON format.
    /// - Parameters:
    ///   - imageUrl: The URL of the image being annotated.
    ///   - imageSize: The size of the image being annotated.
    func save(_ imageUrl: URL, imageSize: CGSize) {
        guard !tree.isEmpty else { return }
        
        do {
            let size = Size(cgSize: imageSize)
            var annotation = AnnotationTree(imageUrl: imageUrl, tree: tree, imageSize: size)
            annotation.resolveNodeNames()
            let data = try encoder.encode(annotation)
            let saveUrl = imageUrl.deletingPathExtension().appendingPathExtension("json")
            try data.write(to: saveUrl)
        } catch {
            print("Error while writing annotation")
        }
    }
    
    /// Load annotation from disk. This triggers a `objectWillChange.send()`.
    /// - Parameter url: The annotation URL on disk.
    func loadAnnotation(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let annotation = try decoder.decode(AnnotationTree.self, from: data)
            objectWillChange.send()
            tree = annotation.tree
            selection = tree.root
        } catch {
            reset()
        }
    }
    
    /// Load annotation from disk. This triggers a `objectWillChange.send()`.
    /// - Parameter imageUrl: The image URL on disk. The annotation should have the
    /// save name with a `.json` extension.
    func loadAnnotation(forImageUrl imageUrl: URL) {
        let url = imageUrl.deletingPathExtension().appendingPathExtension("json")
        loadAnnotation(url: url)
    }
    
    /// Reset both the annotation tree and the selected node to `nil`.
    func reset() {
        objectWillChange.send()
        tree = .init()
        selection = nil
    }
}
