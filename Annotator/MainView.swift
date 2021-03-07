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
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationView {
            SidebarView()
            AnnotationView()
        }
        .frame(minWidth: 1000, minHeight: 600)
        .toolbar(content: toolbarItems)
        .sheet(isPresented: $isPresented, content: SettingsView.init)
    }
    
    func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                Button(action: openPanel) {
                    Image(systemSymbol: .folder)
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: { isPresented.toggle() }) {
                    Image(systemSymbol: .gear)
                }
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

