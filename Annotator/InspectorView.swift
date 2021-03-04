//
//  InspectorView.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import SwiftUI

struct InspectorView: View {
    @State var item: Item<Double> = .stub
    
    var body: some View {
        List {
            OutlineGroup(item, children: \.children) { item in
                switch item.item {
                case .annotation(let annotation):
                    Text("\(annotation.imageURL)")
                case .box:
                    Text("Bounding box")
                case .object(let object):
                    Text("\(object.name)")
                case .keypoint(let keypoint):
                    Text("\(keypoint.name)")
                }
            }
        }
    }
}

struct InspectorView_Previews: PreviewProvider {
    static var previews: some View {
        InspectorView()
    }
}
