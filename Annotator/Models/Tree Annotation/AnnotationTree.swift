//
//  AnnotationTree.swift
//  Annotator
//
//  Created by Louis Lac on 07/03/2021.
//

import Foundation

typealias KeypointNode = Node<Keypoint<Double>>
typealias KeypointTree = Tree<Keypoint<Double>>

struct AnnotationTree {
    var imageUrl: URL
    var tree: KeypointTree
    var imageSize: Size<Double>?
}

extension AnnotationTree {
    mutating func resolveNodeNames() {
        tree.traverse { node in
            if node === tree.root {
                node.value.name = "root"
            } else if node.children.isEmpty {
                node.value.name = "leaf"
            } else {
                node.value.name = "part"
            }
        }
    }
}

//extension AnnotationTree: Equatable, Hashable { }

extension AnnotationTree: Codable {
    enum Keys: String, CodingKey {
        case imageUrl, tree, imageSize
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let stringUrl = try container.decode(String.self, forKey: .imageUrl)
        
        imageUrl = try URL(string: stringUrl).get()
        tree = try container.decode(KeypointTree.self, forKey: .tree)
        imageSize = try container.decode(Size<Double>.self, forKey: .imageSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(imageUrl.path, forKey: .imageUrl)
        try container.encode(tree, forKey: .tree)
        try container.encode(imageSize, forKey: .imageSize)
    }
}
