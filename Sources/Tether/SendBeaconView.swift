//
//  SendBeaconView.swift
//  tether-skip
//
//  Created by Conlan Wilson on 2025-11-01.
//


import SwiftUI
import TetherModel

struct SendBeaconView: View {
    @Environment(AppModel.self) var model: AppModel
    @State internal var note: String = ""
    @State internal var ttl: Int = 300
    @State internal var isSending = false
    @State internal var lastError: String?

    var body: some View {
        @Bindable var model = model
        Form {
            Section("Status") {
                Picker("Status", selection: $model.myStatus) {
                    ForEach(BeaconStatus.allCases) { s in
                        Text(s.label).tag(s)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Details") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Optional note…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $note)
                        .frame(minHeight: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
                HStack {
                    Text("TTL Seconds")
                    Spacer()
                    Button("−") {
                        ttl = max(30, ttl - 30)
                    }
                    .buttonStyle(.bordered)

                    Text("\(ttl)")
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 60, alignment: .center)

                    Button("+") {
                        ttl = min(3600, ttl + 30)
                    }
                    .buttonStyle(.bordered)
                }
                HStack {
                    Text("Group")
                    Spacer()
                    Text(model.groupId).foregroundStyle(.secondary)
                }
            }

            Section {
                Button {
                    Task {
                        await send()
                    }
                } label: {
                    if isSending {
                        ProgressView()
                    } else {
                        Label("Send Beacon", systemImage: "paperplane.circle.fill")
                    }
                }
                .disabled(isSending)
            }

            if let err = lastError {
                Section {
                    Text(err).foregroundStyle(.red)
                }
            }
        }
    }

    @MainActor
        private func send() async {
            isSending = true
            lastError = nil
            model.send()
            isSending = false
        }
}
