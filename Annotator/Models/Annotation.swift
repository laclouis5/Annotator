//
//  Annotation.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import Foundation
import RealModule

struct Point<C: Real> {
    var x, y: C
    
    static var zero: Point { Point(x: .zero, y: .zero) }
}

struct Size<C: Numeric> {
    var width, height: C
    
    static var zero: Size { Size(width: .zero, height: .zero) }
}

extension Size where C: Real {
    func standardized() -> Size {
        Size(width: abs(width), height: abs(height))
    }
}

extension Size where C == CGFloat.NativeType {
    init(cgSize: CGSize) {
        self.width = C(cgSize.width)
        self.height = C(cgSize.height)
    }
}

struct Box<C: Real> {
    var origin: Point<C>
    var size: Size<C>
    
    init(origin: Point<C>, size: Size<C>) {
        self.origin = origin
        self.size = size
    }
    
    init(xMin: C, yMin: C, width: C, height: C) {
        origin = Point(x: xMin, y: yMin)
        size = Size(width: width, height: height)
    }
    
    init(xMin: C, yMin: C, xMax: C, yMax: C) {
        origin = Point(x: xMin, y: yMin)
        size = Size(width: xMax - xMin, height: yMax - yMin)
    }
    
    init(xMid: C, yMid: C, width: C, height: C) {
        origin = Point(x: xMid - width / 2, y: yMid - height / 2)
        size = Size(width: width, height: height)
    }
    
    init(origin: CGPoint, size: CGSize) where C == CGFloat.NativeType {
        self.origin = Point(x: C(origin.x), y: C(origin.y))
        self.size = Size(width: C(size.width), height: C(size.height))
    }
    
    var xMin: C { size.width < 0 ? origin.x + size.width : origin.x }
    var yMin: C { size.height < 0 ? origin.y + size.height : origin.y }
    var xMax: C { size.width < 0 ? origin.x : origin.x + size.width }
    var yMax: C { size.height < 0 ? origin.y : origin.y + size.width }
    
    var xMid: C { origin.x + size.width / 2 }
    var yMid: C { origin.y + size.width / 2 }
    
    var width: C { abs(size.width) }
    var height: C { abs(size.height) }
    
    func standardized() -> Box {
        Box(origin: Point(x: xMin, y: yMin), size: Size(width: width, height: height))
    }
}

struct Keypoint<C: Real> {
    var name: String?
    var x, y: C
}

struct Object<C: Real> {
    var name: String
    var box: Box<C>?
    var keypoints: [Keypoint<C>] = []
}

struct Annotation<C: Real> {
    var imageURL: URL
    var imageSize: Size<C>?
    var objects: [Object<C>] = []
}

// MARK: - Equatable Conformance
extension Size: Equatable where C: Equatable { }

// MARK: - Hashable Conformance
extension Point: Hashable { }
extension Size: Hashable where C: Hashable { }
extension Box: Hashable { }
extension Keypoint: Hashable { }
extension Object: Hashable { }
extension Annotation: Hashable { }

// MARK: - Codable Conformance
extension Point: Codable where C: Codable { }
extension Size: Codable where C: Codable { }
extension Keypoint: Codable where C: Codable { }
extension Object: Codable where C: Codable { }
extension Annotation: Codable where C: Codable { }

extension Box: Codable where C: Codable {
    enum Keys: String, CodingKey {
        case origin, size
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        let box = self.standardized()
        try container.encode(box.origin, forKey: .origin)
        try container.encode(box.size, forKey: .size)
    }
}
