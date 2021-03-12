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
    @StateObject private var imagePreference = ImageScalePreference()
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
        .environmentObject(imagePreference)
    }
    
    func toolbarItems() -> some ToolbarContent {
        Group {
//            min(max(imagePreference.imageScale * scale, 1.0)
            ToolbarItemGroup(placement: .automatic) {
                Button(action: { imagePreference.imageScale = min(max(imagePreference.imageScale / 2, 1.0), 5) }) {
                    Image(systemSymbol: .minusMagnifyingglass)
                }
                Button(action: { imagePreference.imageScale = 1 }) {
                    Image(systemSymbol: ._1Magnifyingglass)
                }
                Button(action: { imagePreference.imageScale = min(max(imagePreference.imageScale * 2, 1.0), 5) }) {
                    Image(systemSymbol: .plusMagnifyingglass)
                }
            }
            
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

