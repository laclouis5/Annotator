//
//  SidebarView.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: ImageStoreController
    
    var body: some View {
        VStack(spacing: 0) {
            List(selection: $store.selection) {
                Section(header: Text("Image List")) {
                    ForEach(store.images, id: \.self) { image in
                        HStack {
                            Text(image.lastPathComponent)
                                .font(Font.body.monospacedDigit())
                            
                            Spacer()
                            
                            if store.isAnnotated(image) {
                                Image(systemSymbol: .aCircleFill)
                            }
                        }
                    }
                }
            }
            
            Divider()

            HStack(spacing: 4) {
                FilterField("Filter", text: $store.filterText)
                
                Image(systemSymbol: .aCircleFill)
                    .foregroundColor(store.filterAnnotated ? .blue : .gray)
                    .onTapGesture {
                        store.filterAnnotated.toggle()
                    }
                    .help("Tap to show only annotated images")
            }
            .padding(4)
        }
        .frame(minWidth: 200)
        .toolbar(content: toolbarItems)
        .listStyle(SidebarListStyle())
    }
    
    func toolbarItems() -> some ToolbarContent {
        ToolbarItem {
            Button(action: toggleSidebar) {
                Image(systemSymbol: .sidebarLeft)
            }
            .help("Tap to hide sidebar")
        }
    }
    
    func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environmentObject(
                ImageStoreController(
                    folder: URL(string: "/Users/louislac/Downloads/Biomass/2021/p0215_0914")
                )
            )
            .frame(width: 200)
    }
}
