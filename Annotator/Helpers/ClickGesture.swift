//
//  ClickGesture.swift
//  Annotator
//
//  Created by Louis Lac on 06/03/2021.
//

import SwiftUI

struct ClickGesture: Gesture {
    let count: Int
    let coordinateSpace: CoordinateSpace
    
    init(count: Int = 1, coordinateSpace: CoordinateSpace = .local) {
        precondition(count > 0, "Count must be greater than or equal to 1.")
        self.count = count
        self.coordinateSpace = coordinateSpace
    }
    
    var body: SimultaneousGesture<TapGesture, DragGesture> {
        TapGesture(count: count)
            .simultaneously(with: DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace))
    }
}
