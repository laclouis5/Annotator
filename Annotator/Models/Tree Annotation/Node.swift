//
//  Node.swift
//  Annotator
//
//  Created by Louis Lac on 07/03/2021.
//

import Foundation

final class Node<Value> {
    var value: Value
    private(set) var children: [Node<Value>]
    weak private(set) var parent: Node<Value>?
 
    init(_ value: Value, children: [Node] = []) {
        self.value = value
        self.children = children
        self.parent = nil
    }
}

extension Node {
    func addChild(_ node: Node) {
        children.append(node)
        node.parent = self
    }
    
    func addChildren(_ nodes: [Node]) {
        children += nodes
        nodes.forEach { $0.parent = self }
    }
    
    @discardableResult
    func add(_ value: Value) -> Node {
        let node = Node(value)
        addChild(node)
        return node
    }
    
    func removeChild(_ node: Node) {
        guard let index = children.firstIndex(where: { $0 === node }) else {
            return
        }
        
        children.remove(at: index)
    }
    
    func emptyChildren() {
        children.removeAll()
    }
    
    func insert(_ node: Node, before child: Node) {
        guard let index = children.firstIndex(where: { $0 === child }) else {
            return
        }

        children.remove(at: index)
        node.addChild(child)
        addChild(node)
    }
    
    var isLeaf: Bool {
        children.isEmpty
    }
    
    var isRoot: Bool {
        self.parent == nil
    }
    
    func insert(_ value: Value, before child: Node) {
        insert(Node(value), before: child)
    }
    
    func resolveParents() {
        traverse { node in
            node.children.forEach { child in
                child.parent = node
            }
        }
    }
}

extension Node {
    func traverse(_ handler: (Node) -> Void) {
        handler(self)
        children.forEach { $0.traverse(handler) }
    }

    func reduce<T>(_ handler: (Node) -> T) -> [T] {
        CollectionOfOne(handler(self)) + children.flatMap { $0.reduce(handler) }
    }
    
    func reduce<T>(_ handler: (Node) -> [T]) -> [T] {
        handler(self) + children.flatMap { $0.reduce(handler) }
    }

    func filter(_ isIncluded: (Node) -> Bool) -> [Node<Value>] {
        reduce { isIncluded($0) ? [$0] : [] }
    }
}

extension Node: Equatable where Value: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.value == rhs.value
    }
}

extension Node: Hashable where Value: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

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

extension Node: Identifiable { }
