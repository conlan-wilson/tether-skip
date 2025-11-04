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

#if !os(Android)
#Preview {
    BeaconListView()
        .environment(AppModel())
}
#endif


#if !os(Android)
struct GlassStartButton: View {
    var title: String = "Start"
    var action: () -> Void
    
    @State internal var isPressed = false
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                // Base glass capsule
                RoundedRectangle(cornerRadius: 28, style: .continuous)             .fill(.ultraThinMaterial)
                    .overlay(
                        // Frosted inner blur & vignette
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), Color.white.opacity(0.15)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ), lineWidth: 1.2
                            )
                    )
                    .background(
                        // Subtle depth gradient under the glass
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.black.opacity(0.25)
                                    ],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .blur(radius: 6)
                    )
                    .overlay(
                        // Specular highlight strip
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.65),
                                        Color.white.opacity(0.10),
                                        .clear
                                    ],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .blendMode(.screen)
                            .opacity(0.7)
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 12) // drop shadow
                    .shadow(color: Color.white.opacity(0.25), radius: 6, x: -2, y: -2) // rim light
            
                // Inner bevel (inset highlight + shadow)
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.55),
                                Color.white.opacity(0.15),
                                Color.black.opacity(0.35)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .blur(radius: 0.6)
                    .padding(2)
                    .blendMode(.overlay)
                    .opacity(0.8)

                // Title with subtle glow
                Text(title.uppercased())
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.85)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.white.opacity(0.6), radius: 6, x: 0, y: 0)
                    .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 2)
            }
            .frame(height: 64)
            .padding(.horizontal, 6)
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .overlay(
                // Top-left glossy flare
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.35), .clear],
                            center: .center, startRadius: 0, endRadius: 80
                        )
                    )
                    .frame(width: 90, height: 90)
                    .offset(x: -70, y: -32)
                    .blur(radius: 10)
                    .allowsHitTesting(false)
            )
            .animation(.spring(response: 0.28, dampingFraction: 0.9), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isPressed { isPressed = true } }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .compositingGroup() // improves blending for glass effects
    }
}
#endif
