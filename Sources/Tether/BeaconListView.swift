//
//  BeaconListView.swift
//  tether-skip
//
//  Created by Conlan Wilson on 2025-11-01.
//


import SwiftUI
import TetherModel

struct BeaconListView: View {
    @Environment(AppModel.self) var model: AppModel

    var body: some View {
        @Bindable var model = model
        List {
            Section {
                HStack {
                    Text("Group")
                    Spacer()
                    TextField("group-id", text: $model.groupId)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }

            if model.beacons.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.title)
                    Text("No active beacons")
                        .font(.headline)
                    Text("Tap Send to publish your status.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 32)
            } else {
                Section("Active (\(model.beacons.count))") {
                    ForEach(model.beacons) { b in
                        BeaconRow(beacon: b)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

internal struct BeaconRow: View {
    let beacon: Beacon

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(beacon.status.label)
                    .font(.headline)
                Spacer()
                Text("TTL \(beacon.ttlSeconds)s")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !beacon.note.isEmpty {
                Text(beacon.note)
            }
            HStack(spacing: 12) {
                Label("Hops \(beacon.hopCount)", systemImage: "arrow.triangle.branch")
                Label(beacon.groupId, systemImage: "person.3")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
