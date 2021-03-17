//
//  InspectorView.swift
//  Annotator
//
//  Created by Louis Lac on 12/03/2021.
//

import SwiftUI

struct InspectorView: View {
    @EnvironmentObject private var labelsController: LabelsController
    @State private var newLabel: String = ""
    
    var body: some View {
        List {
            HStack {
                Picker("Label", selection: $labelsController.selection) {
                    Text("None").tag(String?.none)

                    ForEach(labelsController.labels, id: \.self) { label in
                        Text(label).tag(String?.some(label))
                    }
                }
                
                Button(action: labelsController.removeSelectedLabel) {
                    Image(systemSymbol: .xmarkCircle)
                }
                .disabled(labelsController.isDisabled)
                .buttonStyle(BorderlessButtonStyle())
                .help("Tap to remove the current label")
            }
            
            TextField("New label", text: $newLabel, onCommit: appendLabel)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: labelsController.importLabelsFromJson) {
                Text("Import from json...")
            }
        }
        .frame(width: 200)
        .listStyle(SidebarListStyle())
        
    }
    
    func appendLabel() {
        labelsController.addLabel(newLabel)
        newLabel = ""
    }
}

struct InspectorView_Previews: PreviewProvider {
    static var previews: some View {
        InspectorView()
    }
}
