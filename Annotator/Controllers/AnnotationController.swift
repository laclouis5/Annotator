//
//  AnnotationController.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import Foundation
import Combine

final class AnnotationController: ObservableObject {
    @Published var objects: [Object<Double>]
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    private let decoder = JSONDecoder()
    
    init(objects: [Object<Double>] = []) {
        self.objects = objects
    }
    
    func save(_ imageURL: URL, imageSize: CGSize? = nil) throws {
        let size = imageSize.map(Size.init)
        let annotation = Annotation<Double>(imageURL: imageURL, objects: objects, imageSize: size)
        
        let data = try encoder.encode(annotation)
        
        let saveUrl = imageURL.deletingPathExtension().appendingPathExtension("json")
        
        try data.write(to: saveUrl)
    }
    
    func loadAnnotationFor(imageUrl: URL) {
        let annotation = try? decoder.decode(Annotation<Double>.self, from: Data(contentsOf: imageUrl))
        objects = annotation?.objects ?? []
    }
}
