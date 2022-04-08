//
//  MainView.swift
//  Annotator
//
//  Created by Louis Lac on 03/03/2021.
//

import SwiftUI
import SFSafeSymbols

struct MainView: View {
    @StateObject private var imageStore = ImageStoreController()
    @StateObject private var labelsController = LabelsController()
    
    var body: some View {
        NavigationView {
            SidebarView()
            HStack(spacing: 0) {
                Spacer()
                AnnotationView()
                Spacer()
                InspectorView()
            }
        }
        .frame(minWidth: 1000, minHeight: 600)
        .environmentObject(imageStore)
        .environmentObject(labelsController)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

