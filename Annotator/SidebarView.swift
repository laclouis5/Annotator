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
                    ForEach(store.images, id: \.self, content: rowImageView)
                }
            }
            
            Divider()

            filterView
        }
        .frame(minWidth: 200)
        .toolbar(content: toolbarItems)
        .listStyle(SidebarListStyle())
    }
    
    func rowImageView(_ url: URL) -> some View {
        HStack {
            Text(url.lastPathComponent)
                .font(Font.body.monospacedDigit())
            
            Spacer()
            
            if store.isAnnotated(url) {
                Image(systemSymbol: .aCircleFill)
            }
        }
    }
    
    var filterView: some View {
        HStack(spacing: 4) {
            FilterField("Filter", text: $store.filterText)
            
            Image(systemSymbol: .aCircleFill)
                .foregroundColor(store.filterAnnotated ? .blue : .gray)
                .onTapGesture {
                    store.filterAnnotated.toggle()
                }
                .help("only show annotated images")
        }
        .padding(4)
    }
    
    func toolbarItems() -> some ToolbarContent {
        ToolbarItem {
            Button(action: toggleSidebar) {
                Image(systemSymbol: .sidebarLeft)
            }
            .help("hide sidebar")
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
