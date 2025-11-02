//
//  SettingsView.swift
//  tether-skip
//
//  Created by Conlan Wilson on 2025-11-01.
//


import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) var model: AppModel
    @Binding var appearance: String

    var body: some View {
        @Bindable var model = model
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $appearance) {
                    Text("System").tag("")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
            }

            Section("Group") {
                TextField("group-id", text: $model.groupId)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Section("Debug") {
                Button(role: .destructive) {
                    model.clearLocalBeacons()
                } label: {
                    Label("Clear Local Cache", systemImage: "trash")
                }
            }
        }
    }
}
