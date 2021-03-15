//
//  LabelsController.swift
//  Annotator
//
//  Created by Louis Lac on 14/03/2021.
//

import Foundation
import SwiftUI

final class LabelsController: ObservableObject {
    @Published private(set) var labels: [String] = []
    @Published var selection: String?
    
    func removeSelectedLabel() {
        guard let label = selection, let index = labels.firstIndex(of: label) else { return }
        labels.remove(at: index)
        let indexBefore = labels.index(before: index)
        if indexBefore < 0 {
            self.selection = nil
        } else {
            self.selection = labels[indexBefore]
        }
    }
    
    func addLabel(_ label: String) {
        guard !label.isEmpty else { return }
        labels.append(label)
        selection = label
    }
    
    func importLabelsFromJson() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canHide = true
        panel.allowedContentTypes = [.json]
        
        guard panel.runModal() == .OK else { return }
        guard let fileURL = panel.url else { return }
        guard let data = try? Data(contentsOf: fileURL) else { return }
        guard let labels = try? JSONDecoder().decode([String].self, from: data) else { return }
        
        self.labels = labels
        self.selection = self.labels.first
    }
    
    var isDisabled: Bool {
        selection == nil || labels.isEmpty
    }
}
