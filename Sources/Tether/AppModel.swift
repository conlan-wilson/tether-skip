//
//  AppModel.swift
//  tether-skip
//
//  Created by Conlan Wilson on 2025-10-31.
//

import Observation
import SkipFuse
import TetherModel

@MainActor
@Observable
final public class AppModel {
    public var groupId: String = "public-default"
    public var beacons: [Beacon] = []
    public var myStatus: BeaconStatus = .ok
    public var note: String = ""
    public var ttlMinutes: Int = 15

    let service: BeaconService = LocalBeaconService.shared
    var token: BeaconService.ListenerToken?

    public init() {
        token = service.addListener(groupId: groupId) { [weak self] snapshot in
            Task { @MainActor in
                self?.beacons = snapshot
            }
        }
    }

    @MainActor
    deinit {
    
            if let token {
                let svc = service
            
                    svc.removeListener(token)
                
            }
       
    }

    public func send(status: BeaconStatus? = nil) {
        Task {
            try? await service.sendBeacon(
                status: status ?? myStatus,
                note: note,
                ttlSeconds: max(1, ttlMinutes) * 60,
                groupId: groupId
            )
            await MainActor.run { self.note = "" }
        }
    }

    public var myShortId: String {
        let id = DeviceID.current.replacingOccurrences(of: "-", with: "")
        return String(id.suffix(6))
    }
    
    @MainActor public func clearLocalBeacons() { beacons.removeAll() }
}
