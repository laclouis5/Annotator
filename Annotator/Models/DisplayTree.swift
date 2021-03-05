//
//  DisplayTree.swift
//  Annotator
//
//  Created by Louis Lac on 05/03/2021.
//

import Foundation
import RealModule

enum AnnotationItem<C: Real>: Hashable {
    case annotation(Annotation<C>)
    case object(Object<C>)
    case keypoint(Keypoint<C>)
    case box(Box<C>)
}

struct Item<C: Real>: Hashable, Identifiable {
    var item: AnnotationItem<C>
    var children: [Item]?
    var id: Self { self }
    
    init(_ item: AnnotationItem<C>, children: [Item]? = nil) {
        self.item = item
        self.children = children
    }
    
    init(from annotation: Annotation<C>) {
        self.item = .annotation(annotation)
        self.children = annotation.objects.map(Item.init)
    }
    
    init(from object: Object<C>) {
        self.item = .object(object)
        self.children = object.keypoints.map(Item.init)
        if let boxItem = Item(from: object.box) {
            self.children!.append(boxItem)
        }
    }
    
    init(from keypoint: Keypoint<C>) {
        self.item = .keypoint(keypoint)
        self.children = nil
    }
    
    init?(from box: Box<C>?) {
        guard let box = box else {
            return nil
        }
        
        self.item = .box(box)
        self.children = nil
    }
}

extension Annotation {
    static var stub: Self {
        Annotation<C>(
            imageURL: URL(string: "test")!,
            objects: [
                Object(
                    name: "maize",
                    box: Box(xMin: 20, yMin: 40, width: 200, height: 100),
                    keypoints: [
                        Keypoint(name: "stem", x: 100, y: 50),
                        Keypoint(name: "leaf", x: 120, y: 70),
                    ]
                ),
                Object(
                    name: "bean",
                    box: Box(xMin: 200, yMin: 100, width: 100, height: 100),
                    keypoints: [
                        Keypoint(name: "stem", x: 220, y: 120),
                        Keypoint(name: "leaf", x: 210, y: 190),
                        Keypoint(name: "leaf", x: 290, y: 150),
                    ]
                )
            ]
        )
    }
}

extension Item {
    static var stub: Self {
        Item(from: Annotation.stub)
    }
}
