//
//  MainView.swift
//  Annotator
//
//  Created by Louis Lac on 03/03/2021.
//

import SwiftUI
import SFSafeSymbols

struct MainView: View {
    @EnvironmentObject private var store: ImageStoreController
    
    var body: some View {
        NavigationView {
            SidebarView()
            AnnotationView()
        }
        .frame(minWidth: 1000, minHeight: 600)
        .toolbar(content: toolbarItems)
    }
    
    func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button(action: openPanel) {
                Image(systemSymbol: .folder)
            }
        }
    }
    
    func openPanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canHide = true
        
        if panel.runModal() == .OK {
            store.folder = panel.url
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

