//
//  Sequence.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import Foundation

extension Sequence {
    func sorted<C: Comparable>(by keyPath: KeyPath<Element, C>, reversed: Bool = false) -> Array<Element> {
        let comparator: (C, C) -> Bool = reversed ? (>) : (<)
        return sorted { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    }
}

extension RandomAccessCollection where Self: MutableCollection {
    mutating func sort<C: Comparable>(by keyPath: KeyPath<Element, C>, reversed: Bool = false) {
        let comparator: (C, C) -> Bool = reversed ? (>) : (<)
        self.sort { comparator($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    }
}

extension Sequence where Element: Sequence {
    func flatMap() -> [Element.Element] {
        flatMap { $0 }
    }
}
