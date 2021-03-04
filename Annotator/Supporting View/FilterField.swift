//
//  FilterField.swift
//  Annotator
//
//  Created by Louis Lac on 04/03/2021.
//

import SwiftUI

struct FilterField: NSViewRepresentable {
    /// The text entered by the user.
    @Binding var text: String

    /// Placeholder text for the text field.
    let prompt: String

    init(_ prompt: String, text: Binding<String>) {
        self.prompt = prompt
        _text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(binding: $text)
    }

    func makeNSView(context: Context) -> NSSearchField {
        let tf = NSSearchField(string: text)
        tf.placeholderString = prompt
        tf.delegate = context.coordinator
        tf.bezelStyle = .roundedBezel
        tf.focusRingType = .none
        return tf
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }

    class Coordinator: NSObject, NSSearchFieldDelegate {
        let binding: Binding<String>

        init(binding: Binding<String>) {
            self.binding = binding
            super.init()
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            binding.wrappedValue = field.stringValue
        }
    }
}
