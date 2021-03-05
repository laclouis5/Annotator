//
//  TreeAnnotation.swift
//  Annotator
//
//  Created by Louis Lac on 05/03/2021.
//

import Foundation
import RealModule
import Combine

final class Node<Value>: ObservableObject {
    @Published var value: Value
    @Published var children: [Node<Value>]
//    @Published var id: UUID
    
    init(_ value: Value, children: [Node<Value>] = []/*, id: UUID = UUID()*/) {
        self.value = value
        self.children = children
//        self.id = id
    }
}

/// Tree must be declared as an Observable object to be able to update the views.
/// A notification should be send via `objectWillChange.send()` each time
/// the tree structure is modified (add a node, changed a value, ...).
final class Tree<Value> {
    var root: Node<Value>?
//    var id: UUID
    
    init(root: Node<Value>? = nil/*, id: UUID = UUID()*/) {
        self.root = root
//        self.id = id
    }
}

extension Node {
    func traverse(_ handler: (Node<Value>) -> Void) {
        handler(self)
        children.forEach { $0.traverse(handler) }
    }

    func reduce<T>(_ handler: (Node<Value>) -> T) -> [T] {
        CollectionOfOne(handler(self)) + children.flatMap { $0.reduce(handler) }
    }
    
    func reduce<T>(_ handler: (Node<Value>) -> [T]) -> [T] {
        handler(self) + children.flatMap { $0.reduce(handler) }
    }
}

extension Node {
    func filter(_ isIncluded: (Node<Value>) -> Bool) -> [Node<Value>] {
        reduce { isIncluded($0) ? [$0] : [] }
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

// MARK: - Equatable Conformances
extension Node: Equatable where Value: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.value == rhs.value &&
        lhs.children == rhs.children
    }
}

extension Tree: Equatable where Value: Equatable {
    static func == (lhs: Tree, rhs: Tree) -> Bool {
        lhs.root == rhs.root
    }
}

// MARK: - Hashable Conformances
extension Node: Hashable where Value: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(children)
    }
}

extension Tree: Hashable where Value: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(root)
    }
}

// MARK: - Codable Conformances
extension Node: Codable where Value: Codable {
    enum Keys: String, CodingKey {
        case value, children
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let value = try container.decode(Value.self, forKey: .value)
        let children = try container.decode([Node<Value>].self, forKey: .children)
        self.init(value, children: children)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(value, forKey: .value)
        try container.encode(children, forKey: .children)
    }
}

extension Tree: Codable where Value: Codable {
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let root = try container.decode(Node<Value>?.self)
        self.init(root: root)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(root)
    }
}

// MARK: - Identifiable Conformances
extension Node: Identifiable { }
extension Tree: Identifiable { }

// MARK: - Typealiases
typealias KeypointNode = Node<Keypoint<Double>>
typealias KeypointTree = Tree<Keypoint<Double>>

struct AnnotationTree: Equatable, Hashable, Codable, Identifiable {
    var imageUrl: URL
    var tree: KeypointTree
    var imageSize: Size<Double>?
    var id: UUID = UUID()
}
