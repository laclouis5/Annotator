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
    @StateObject private var labelsController = LabelsController()
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationView {
            SidebarView()
            HStack(spacing: 0) {
                Spacer()
                AnnotationView()
                    .toolbar(content: toolbarItems)
                Spacer()
                InspectorView()
            }
        }
        .frame(minWidth: 1000, minHeight: 600)
        .sheet(isPresented: $isPresented, content: SettingsView.init)
        .environmentObject(imageStore)
        .environmentObject(imagePreference)
        .environmentObject(labelsController)
    }
    
    func toolbarItems() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: imagePreference.decreaseImageScale) {
                    Image(systemSymbol: .minusMagnifyingglass)
                }
                .help("Tap to decrease the image size")
                
                Button(action: imagePreference.resetImageScale) {
                    Image(systemSymbol: ._1Magnifyingglass)
                }
                .help("Tap to reset the image size to default")
                
                Button(action: imagePreference.increaseImageScale) {
                    Image(systemSymbol: .plusMagnifyingglass)
                }
                .help("Tap to increase image size")
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: { isPresented.toggle() }) {
                    Image(systemSymbol: .gear)
                }
                .help("Open settings")
            }

            ToolbarItem(placement: .navigation) {
                Button(action: openPanel) {
                    Image(systemSymbol: .folder)
                }
                .help("Tap to open a folder")
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

