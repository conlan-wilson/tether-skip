//
//  Beacon.swift
//  tether-skip
//
//  Created by Conlan Wilson on 2025-10-31.
//

import Foundation

public enum BeaconStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case ok, help, moving
    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .ok: return "OK"
        case .help: return "Need help"
        case .moving: return "Moving"
        }
    }
}

public struct Beacon: Identifiable, Codable, Equatable, Sendable {
    public var id: String
    public var userId: String
    public var groupId: String
    public var status: BeaconStatus
    public var note: String
    public var ttlSeconds: Int
    public var createdAt: Date
    public var expiresAt: Date
    public var hopCount: Int

    public init(id: String, userId: String, groupId: String, status: BeaconStatus,
                note: String, ttlSeconds: Int, createdAt: Date, expiresAt: Date, hopCount: Int) {
        self.id = id; self.userId = userId; self.groupId = groupId; self.status = status
        self.note = note; self.ttlSeconds = ttlSeconds; self.createdAt = createdAt
        self.expiresAt = expiresAt; self.hopCount = hopCount
    }

    public var isExpired: Bool { Date() >= expiresAt }
}
