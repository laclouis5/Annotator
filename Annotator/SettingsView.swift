//
//  SettingsView.swift
//  Annotator
//
//  Created by Louis Lac on 07/03/2021.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("keypointRadius") private var radius: Double = 6
    @AppStorage("keypointOpacity") private var opacity: Double = 2/3
    @State private var leafColor: Color = .green
    
    @Environment(\.presentationMode) var presentationMode
    
    static var percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
    
    func percent(_ number: Double) -> String {
        Self.percentFormatter.string(from: number as NSNumber)!
    }
    
    var body: some View {
        Form {
            Section(header: Text("Visual Interface").font(.headline)) {
                Slider(
                    value: $radius,
                    in: 2...20,
                    minimumValueLabel: Text(""),
                    maximumValueLabel: Text("\(Int(radius))").font(Font.body.monospacedDigit())
                ) {
                    Text("Keypoint radius")
                }
                
                Slider(
                    value: $opacity,
                    in: 0.1...1.0,
                    minimumValueLabel: Text(""),
                    maximumValueLabel: Text(percent(opacity)).font(Font.body.monospacedDigit())
                ) {
                    Text("Keypoint opacity")
                }
            }
            
            Spacer()
                .frame(height: 20)
            
            HStack {
                Button("Restore Defaults") {
                    radius = 6
                    opacity = 2/3
                }
                
                Spacer()

                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .frame(width: 400, height: 400)
    }
}
