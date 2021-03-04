//
//  AnnotationController.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import Foundation
import Combine
import RealModule

final class AnnotationController: ObservableObject {
    @Published var objects: [Object<Double>]
    
    init(objects: [Object<Double>] = []) {
        self.objects = objects
    }
}
