//
//  ActiveGameSnapshot.swift
//  ChessClock
//
//  Created by Codex on 04/08/2026.
//

import Foundation

struct ActiveGameSnapshot: Codable, Equatable {
    let timeControl: TimeControl
    let colorPreset: ClockColorPreset
    let whiteRemaining: TimeInterval
    let blackRemaining: TimeInterval
    let activePlayer: PlayerSide?
    let state: ClockState
    let persistedAt: Date
}

extension ActiveGameSnapshot {
    struct ClockValues {
        let whiteRemaining: TimeInterval
        let blackRemaining: TimeInterval
        let activePlayer: PlayerSide?
        let state: ClockState
    }
}

enum ActiveGamePersistence {
    private static let key = "activeGameSnapshot"

    static func load() -> ActiveGameSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }

        do {
            return try JSONDecoder().decode(ActiveGameSnapshot.self, from: data)
        } catch {
            clear()
            return nil
        }
    }

    static func save(_ snapshot: ActiveGameSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
