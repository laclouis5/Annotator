//
//  DebugPrint.swift
//  Annotator
//
//  Created by Louis Lac on 06/03/2021.
//

import SwiftUI

extension View {
    func debugPrint(_ items: Any...) -> Self {
        #if DEBUG
        print(items)
        #endif
        return self
    }
}
