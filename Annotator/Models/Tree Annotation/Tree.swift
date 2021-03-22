//
//  Tree.swift
//  Annotator
//
//  Created by Louis Lac on 07/03/2021.
//

import Foundation

final class Tree<Value> {
    var root: Node<Value>?
    
    init(root: Node<Value>? = nil) {
        self.root = root
    }
}

extension Tree {
    var isEmpty: Bool {
        root == nil
    }
    
    func resolveParents() {
        root?.resolveParents()
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
