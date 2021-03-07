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
    
    typealias Value = SimultaneousGesture<TapGesture, DragGesture>.Value
    
    init(count: Int = 1, coordinateSpace: CoordinateSpace = .local) {
        precondition(count > 0, "Count must be greater than or equal to 1.")
        self.count = count
        self.coordinateSpace = coordinateSpace
    }
    
    var body: SimultaneousGesture<TapGesture, DragGesture> {
        TapGesture(count: count)
            .simultaneously(with: DragGesture(minimumDistance: 0, coordinateSpace: coordinateSpace))
    }
    
    func onEnded(perform action: @escaping (CGPoint) -> Void) -> some Gesture {
        ClickGesture(count: count, coordinateSpace: coordinateSpace)
            .onEnded { (value: Value) -> Void in
                guard value.first != nil else { return }
                guard let startLocation = value.second?.startLocation else { return }
                guard let endLocation = value.second?.location else { return }
                guard ((startLocation.x-1)...(startLocation.x+1)).contains(endLocation.x),
                      ((startLocation.y-1)...(startLocation.y+1)).contains(endLocation.y) else { return }
                
                action(startLocation)
            }
    }
}

extension View {
    func onClickGesture(
        count: Int,
        coordinateSpace: CoordinateSpace = .local,
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        gesture(ClickGesture(count: count, coordinateSpace: coordinateSpace)
            .onEnded(perform: action)
        )
    }
    
    func onClickGesture(
        count: Int,
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        onClickGesture(count: count, coordinateSpace: .local, perform: action)
    }
    
    func onClickGesture(
        perform action: @escaping (CGPoint) -> Void
    ) -> some View {
        onClickGesture(count: 1, coordinateSpace: .local, perform: action)
    }
}
