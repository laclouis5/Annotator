//
//  LabelsController.swift
//  Annotator
//
//  Created by Louis Lac on 14/03/2021.
//

import Foundation
import SwiftUI

final class LabelsController: ObservableObject {
    /// A list of labels for annotation.
    @Published private(set) var labels: [String] = []
    
    /// The selected label used to annotate nodes.
    @Published var selection: String?
    
    /// Remove the current selection if present in the labels list.
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
    
    /// Add a label to the labels list. If the label is empty nothing
    /// is added.
    /// - Parameter label: the label to add.
    func addLabel(_ label: String) {
        guard !label.isEmpty else { return }
        labels.append(label)
        selection = label
    }
    
    /// Import labels from a user-selected json file.
    /// Example json file: `["cat", "dog", "cow"]`
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
    
    /// Returns `true` if selection is nil and the label
    /// list is empty.
    var isDisabled: Bool {
        selection == nil || labels.isEmpty
    }
}
