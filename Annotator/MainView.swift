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
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationView {
            SidebarView()
            AnnotationView()
                .toolbar(content: toolbarItems)
        }
        .frame(minWidth: 1000, minHeight: 600)
        .sheet(isPresented: $isPresented, content: SettingsView.init)
        .environmentObject(imageStore)
    }
    
    func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .automatic) {
                Button(action: { isPresented.toggle() }) {
                    Image(systemSymbol: .gear)
                }
            }

            ToolbarItem(placement: .navigation) {
                Button(action: openPanel) {
                    Image(systemSymbol: .folder)
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
            imageStore.folder = panel.url
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

