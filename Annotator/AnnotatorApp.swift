//
//  AnnotatorApp.swift
//  Annotator
//
//  Created by Louis Lac on 03/03/2021.
//

import SwiftUI

@main
struct AnnotatorApp: App {
    @StateObject private var imageStore = ImageStoreController(folder: nil)
    @StateObject private var annotationController = AnnotationController()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(imageStore)
                .environmentObject(annotationController)
        }
        .commands {
            ToolbarCommands()
            SidebarCommands()
        }
    }
}
