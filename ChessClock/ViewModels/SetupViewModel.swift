//
//  SetupViewModel.swift
//  ChessClock
//
//  Created by Jan Royal on 26/12/2025.
//

import Foundation
import Combine

final class SetupViewModel: ObservableObject {
    private static let clockColorPresetStorageKey = "selectedClockColorPreset"

    @Published var selectedTimeControl: TimeControl
    @Published var customMinutes: Int = 10
    @Published var customIncrement: Int = 0
    @Published var whiteOddsMinutes: String = ""
    @Published var whiteOddsSeconds: String = ""
    @Published var blackOddsMinutes: String = ""
    @Published var blackOddsSeconds: String = ""
    @Published var whiteOddsIncrement: Int = 0
    @Published var blackOddsIncrement: Int = 0
    @Published var selectedClockColorPreset: ClockColorPreset {
        didSet {
            UserDefaults.standard.set(selectedClockColorPreset.rawValue, forKey: Self.clockColorPresetStorageKey)
        }
    }

    let sections: [TimeControlSection] = [
        TimeControlSection(
            name: .bullet,
            options: [
                TimeControl(name: .bullet, minutes: 1, seconds: 0, increment: 0, label: "1 min", advanced: false),
                TimeControl(name: .bullet, minutes: 1, seconds: 0, increment: 1, label: "1 | 1", advanced: false),
                TimeControl(name: .bullet, minutes: 2, seconds: 0, increment: 1, label: "2 | 1", advanced: false),
                TimeControl(name: .bullet, minutes: 0, seconds: 30, increment: 0, label: "30 sec", advanced: false),
                TimeControl(name: .bullet, minutes: 0, seconds: 20, increment: 1, label: "20 sec | 1", advanced: true)
            ]
        ),
        TimeControlSection(
            name: .blitz,
            options: [
                TimeControl(name: .blitz, minutes: 3, seconds: 0, increment: 0, label: "3 min", advanced: false),
                TimeControl(name: .blitz, minutes: 3, seconds: 0, increment: 2, label: "3 | 2", advanced: false),
                TimeControl(name: .blitz, minutes: 5, seconds: 0, increment: 0, label: "5 min", advanced: false),
                TimeControl(name: .blitz, minutes: 5, seconds: 0, increment: 5, label: "5 | 5", advanced: false),
                TimeControl(name: .blitz, minutes: 5, seconds: 0, increment: 2, label: "5 | 2", advanced: true)
            ]
        ),
        TimeControlSection(
            name: .rapid,
            options: [
                TimeControl(name: .rapid, minutes: 10, seconds: 0, increment: 0, label: "10 min", advanced: false),
                TimeControl(name: .rapid, minutes: 15, seconds: 0, increment: 10, label: "15 | 10", advanced: false),
                TimeControl(name: .rapid, minutes: 30, seconds: 0, increment: 0, label: "30 min", advanced: false),
                TimeControl(name: .rapid, minutes: 10, seconds: 0, increment: 5, label: "10 | 5", advanced: false),
                TimeControl(name: .rapid, minutes: 20, seconds: 0, increment: 0, label: "20 min", advanced: false),
                TimeControl(name: .rapid, minutes: 60, seconds: 0, increment: 0, label: "60 min", advanced: false)
            ]
        ),
        TimeControlSection(
            name: .daily,
            options: [
                TimeControl(name: .daily, minutes: 1_440, seconds: 0, increment: 0, label: "1 day", advanced: false),
                TimeControl(name: .daily, minutes: 4_320, seconds: 0, increment: 0, label: "3 days", advanced: false),
                TimeControl(name: .daily, minutes: 10_080, seconds: 0, increment: 0, label: "7 days", advanced: false),
                TimeControl(name: .daily, minutes: 2_880, seconds: 0, increment: 0, label: "2 days", advanced: false),
                TimeControl(name: .daily, minutes: 7_200, seconds: 0, increment: 0, label: "5 days", advanced: false),
                TimeControl(name: .daily, minutes: 20_160, seconds: 0, increment: 0, label: "14 days", advanced: false)
            ]
        )
    ]

    init() {
        selectedTimeControl = TimeControl(name: .blitz, minutes: 3, seconds: 0, increment: 2, label: "3 | 2", advanced: false)
        selectedClockColorPreset = Self.savedClockColorPreset()
    }

    var customTimeControl: TimeControl {
        TimeControl(
            name: .custom,
            minutes: max(0, customMinutes),
            seconds: 0,
            increment: max(0, customIncrement),
            label: "\(max(0, customMinutes)) | \(max(0, customIncrement))",
            advanced: true
        )
    }

    var oddsTimeControl: TimeControl {
        let whiteTotal = parsedTotalSeconds(minutes: whiteOddsMinutes, seconds: whiteOddsSeconds)
        let blackTotal = parsedTotalSeconds(minutes: blackOddsMinutes, seconds: blackOddsSeconds)

        return TimeControl(
            name: .odds,
            minutes: max(1, whiteTotal) / 60,
            seconds: max(1, whiteTotal) % 60,
            increment: 0,
            label: oddsSelectionLabel,
            advanced: true,
            whiteStartingSeconds: max(1, whiteTotal),
            blackStartingSeconds: max(1, blackTotal),
            whiteIncrementSeconds: max(0, whiteOddsIncrement),
            blackIncrementSeconds: max(0, blackOddsIncrement)
        )
    }

    var oddsSelectionLabel: String {
        let whiteTotal = parsedTotalSeconds(minutes: whiteOddsMinutes, seconds: whiteOddsSeconds)
        let blackTotal = parsedTotalSeconds(minutes: blackOddsMinutes, seconds: blackOddsSeconds)
        return "W \(formattedOddsLabel(seconds: whiteTotal)) +\(max(0, whiteOddsIncrement)) / B \(formattedOddsLabel(seconds: blackTotal)) +\(max(0, blackOddsIncrement))"
    }

    var effectiveSelection: TimeControl {
        switch selectedTimeControl.name {
        case .custom:
            return customTimeControl
        case .odds:
            return oddsTimeControl
        default:
            return selectedTimeControl
        }
    }

    var defaultTimeControl: TimeControl {
        sections
            .flatMap(\.options)
            .first { $0.name == .blitz && $0.label == "3 | 2" } ?? selectedTimeControl
    }

    func select(_ timeControl: TimeControl) {
        selectedTimeControl = timeControl
    }

    func selectCustom() {
        selectedTimeControl = customTimeControl
    }

    func selectOdds() {
        seedOddsFieldsIfNeeded()
        selectedTimeControl = oddsTimeControl
    }

    func resetHiddenSelectionIfNeeded() {
        guard selectedTimeControl.name == .daily || selectedTimeControl.name == .custom || selectedTimeControl.name == .odds else { return }
        selectedTimeControl = defaultTimeControl
    }

    private func parsedTotalSeconds(minutes: String, seconds: String) -> Int {
        let minuteValue = max(0, Int(minutes) ?? 0)
        let secondValue = min(59, max(0, Int(seconds) ?? 0))
        return minuteValue * 60 + secondValue
    }

    func seedOddsFieldsIfNeeded() {
        guard whiteOddsMinutes.isEmpty,
              whiteOddsSeconds.isEmpty,
              blackOddsMinutes.isEmpty,
              blackOddsSeconds.isEmpty
        else { return }

        let base = selectedTimeControl.name == .custom ? customTimeControl : selectedTimeControl
        whiteOddsMinutes = "\(base.totalSeconds / 60)"
        whiteOddsSeconds = base.totalSeconds % 60 == 0 ? "" : "\(base.totalSeconds % 60)"
        blackOddsMinutes = "\(base.totalSeconds / 60)"
        blackOddsSeconds = base.totalSeconds % 60 == 0 ? "" : "\(base.totalSeconds % 60)"
        whiteOddsIncrement = base.whiteIncrement
        blackOddsIncrement = base.blackIncrement
    }

    private func formattedOddsLabel(seconds: Int) -> String {
        let safeSeconds = max(1, seconds)
        let minutes = safeSeconds / 60
        let seconds = safeSeconds % 60

        if seconds == 0 {
            return "\(minutes)m"
        }

        return "\(minutes):\(String(format: "%02d", seconds))"
    }

    private static func savedClockColorPreset() -> ClockColorPreset {
        guard let rawValue = UserDefaults.standard.string(forKey: clockColorPresetStorageKey) else { return .green }
        return ClockColorPreset(rawValue: rawValue) ?? .green
    }
}

struct TimeControlSection: Identifiable {
    var id: TimeControlName { name }

    let name: TimeControlName
    let options: [TimeControl]
}
