//
//  LocalBeaconService.swift
//  tether-skip
//
//  Created by Conlan Wilson on 2025-10-31.
//

import Foundation

@MainActor
public protocol BeaconService {
    typealias ListenerToken = UUID

    /// Start listening for active beacons in a group.
    @discardableResult
    func addListener(groupId: String, onChange: @MainActor @escaping ([Beacon]) -> Void) -> ListenerToken

    /// Stop listening.
    func removeListener(_ token: ListenerToken)

    /// Publish a new beacon.
    func sendBeacon(
        status: BeaconStatus,
        note: String,
        ttlSeconds: Int,
        groupId: String
    ) async throws
}


@MainActor
public final class LocalBeaconService: BeaconService {
    public static let shared = LocalBeaconService()

    private struct Listener {
        let groupId: String
        let handler: @MainActor ([Beacon]) -> Void
    }

    private var listeners: [UUID: Listener] = [:]
    private var beacons: [Beacon] = []
    private let url: URL

    private var timer: DispatchSourceTimer?

    private init() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = dir.appendingPathComponent("beacons.json")
        load()
        startPruneTimer()
    }

    // MARK: - BeaconService
    @discardableResult
    public func addListener(groupId: String, onChange: @MainActor @escaping ([Beacon]) -> Void) -> UUID {
        let token = UUID()
        listeners[token] = Listener(groupId: groupId, handler: onChange)
        onChange(self.filteredBeacons(for: groupId))
        return token
    }

    public func removeListener(_ token: UUID) {
        listeners.removeValue(forKey: token)
    }

    public func sendBeacon(status: BeaconStatus, note: String, ttlSeconds: Int, groupId: String) async throws {
        let now = Date()
        let ttl = max(60, ttlSeconds)
        let beacon = Beacon(
            id: UUID().uuidString,
            userId: DeviceID.current,
            groupId: groupId,
            status: status,
            note: String(note.prefix(120)),
            ttlSeconds: ttl,
            createdAt: now,
            expiresAt: now.addingTimeInterval(TimeInterval(ttl)),
            hopCount: 0
        )
        beacons.insert(beacon, at: 0)
        save()
        notify(groupId: groupId)
    }

    // MARK: - Internals
    private func filteredBeacons(for groupId: String) -> [Beacon] {
        let now = Date()
        return beacons.filter { $0.groupId == groupId && now < $0.expiresAt }
    }

    private func notify(groupId: String) {
        let snapshot = filteredBeacons(for: groupId)
        for l in listeners.values where l.groupId == groupId {
            l.handler(snapshot)
        }
    }

    private func pruneExpired() {
        let before = beacons.count
        let now = Date()
        beacons.removeAll { now >= $0.expiresAt }
        if beacons.count != before {
            save()
            let groups = Set(listeners.values.map { $0.groupId })
            groups.forEach { notify(groupId: $0) }
        }
    }

    private func startPruneTimer() {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + 5, repeating: 5)
        t.setEventHandler { [weak self] in
            guard let self else { return }
            self.pruneExpired()
        }
        t.resume()
        timer = t
    }

    // MARK: - Persistence
    private func load() {
        if let data = try? Data(contentsOf: url),
           let items = try? JSONDecoder().decode([Beacon].self, from: data) {
            beacons = items
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(beacons) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
