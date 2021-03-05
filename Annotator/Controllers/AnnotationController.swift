//
//  AnnotationController.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import Foundation
import Combine

final class AnnotationController: ObservableObject {
    @Published var tree: KeypointTree
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
    
    func save(_ imageUrl: URL, imageSize: CGSize) throws {
        let size = Size(cgSize: imageSize)
        let annotation = AnnotationTree(imageUrl: imageUrl, tree: tree, imageSize: size)
        let data = try encoder.encode(annotation)
        let saveUrl = imageUrl.deletingPathExtension().appendingPathExtension("json")
        try data.write(to: saveUrl)
    }
    
    func load(fileUrl: URL) throws {
        let data = try Data(contentsOf: fileUrl)
        let annotation = try decoder.decode(AnnotationTree.self, from: data)
        tree = annotation.tree
    }
    
//    func save(_ imageURL: URL, imageSize: CGSize? = nil) throws {
//        let size = imageSize.map(Size.init)
//        let annotation = Annotation<Double>(imageURL: imageURL, objects: objects, imageSize: size)
//
//        let data = try encoder.encode(annotation)
//
//        let saveUrl = imageURL.deletingPathExtension().appendingPathExtension("json")
//
//        try data.write(to: saveUrl)
//    }
//
//    func loadAnnotationFor(imageUrl: URL) {
//        let annotation = try? decoder.decode(Annotation<Double>.self, from: Data(contentsOf: imageUrl))
//        objects = annotation?.objects ?? []
//    }
}
