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
                        Text(image.lastPathComponent)
                    }
                }
            }

            Divider()

            FilterField("Filter", text: store.binding(for: \.filterText))
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
        }
    }
    
    func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
