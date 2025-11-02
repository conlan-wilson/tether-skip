//
//  DeviceID.swift
//  tether-skip
//
//  Created by Conlan Wilson on 2025-10-31.
//

import Foundation

public enum DeviceID {
    private static let key = "tether.deviceId"

    @MainActor
    public static var current: String = {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: key) { return saved }
        let id = UUID().uuidString.lowercased()
        defaults.set(id, forKey: key)
        return id
    }()
}
