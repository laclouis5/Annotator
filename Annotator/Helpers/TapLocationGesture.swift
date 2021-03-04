//
//  TapLocationGesture.swift
//  Annotator
//
//  Created by Louis Lac on 03/03/2021.
//

import SwiftUI
import AppKit

public extension View {
    func onTapWithLocation(count: Int = 1, coordinateSpace: CoordinateSpace = .local, _ tapHandler: @escaping (CGPoint) -> Void) -> some View {
        modifier(TapLocationViewModifier(tapHandler: tapHandler, coordinateSpace: coordinateSpace, count: count))
    }
}

fileprivate struct TapLocationViewModifier: ViewModifier {
    let tapHandler: (CGPoint) -> Void
    let coordinateSpace: CoordinateSpace
    let count: Int
    
    func body(content: Content) -> some View {
        content.overlay(
            TapLocationBackground(tapHandler: tapHandler, coordinateSpace: coordinateSpace, numberOfClicks: count)
        )
    }
}

fileprivate struct TapLocationBackground: NSViewRepresentable {
    let tapHandler: (CGPoint) -> Void
    let coordinateSpace: CoordinateSpace
    let numberOfClicks: Int
    
    func makeNSView(context: NSViewRepresentableContext<TapLocationBackground>) -> NSView {
        let v = NSView(frame: .zero)
        let gesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        gesture.numberOfClicksRequired = numberOfClicks
        v.addGestureRecognizer(gesture)
        return v
    }
    
    final class Coordinator: NSObject {
        let tapHandler: (CGPoint) -> Void
        let coordinateSpace: CoordinateSpace
        
        init(handler: @escaping ((CGPoint) -> Void), coordinateSpace: CoordinateSpace) {
            self.tapHandler = handler
            self.coordinateSpace = coordinateSpace
        }
        
        @objc func tapped(gesture: NSClickGestureRecognizer) {
            let height = gesture.view!.bounds.height
            var point = coordinateSpace == .local
                ? gesture.location(in: gesture.view)
                : gesture.location(in: nil)
            point.y = height - point.y
            tapHandler(point)
        }
    }
    
    func makeCoordinator() -> TapLocationBackground.Coordinator {
        Coordinator(handler: tapHandler, coordinateSpace: coordinateSpace)
    }
    
    func updateNSView(_: NSView, context _: NSViewRepresentableContext<TapLocationBackground>) { }
}
