//
//  Tree.swift
//  Annotator
//
//  Created by Louis Lac on 07/03/2021.
//

import Foundation

/// Tree must be declared as an Observable object to be able to update the views.
/// A notification should be send via `objectWillChange.send()` each time
/// the tree structure is modified (add a node, changed a value, ...).
final class Tree<Value>: ObservableObject {
    var root: Node<Value>?
    
    init(root: Node<Value>? = nil) {
        self.root = root
        root?.parent = nil
    }
}

extension Tree {
    var isEmpty: Bool {
        root == nil
    }
    
    func resolveParents() {
        root?.traverse { node in
            node.children.forEach { child in
                child.parent = node
            }
        }
    }
}

extension Tree {
    func traverse(_ handler: (Node<Value>) -> Void) {
        root?.traverse(handler)
    }

    func reduce<T>(_ handler: (Node<Value>) -> [T]) -> [T] {
        root?.reduce(handler) ?? []
    }

    func reduce<T>(_ handler: (Node<Value>) -> T) -> [T] {
        root?.reduce(handler) ?? []
    }
    
    func filter(_ isIncluded: (Node<Value>) -> Bool) -> [Node<Value>] {
        reduce { isIncluded($0) ? [$0] : [] }
    }
}

extension Tree: Equatable where Value: Equatable {
    static func == (lhs: Tree, rhs: Tree) -> Bool {
        lhs.root == rhs.root
    }
}

extension Tree: Hashable where Value: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(root)
    }
}

extension Tree: Codable where Value: Codable {
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let root = try container.decode(Node<Value>?.self)
        self.init(root: root)
        self.resolveParents()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(root)
    }
}

extension Tree: Identifiable { }
