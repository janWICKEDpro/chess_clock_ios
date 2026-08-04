//
//  SetupViewModel.swift
//  ChessClock
//
//  Created by Jan Royal on 26/12/2025.
//

import Foundation
import Combine

final class SetupViewModel: ObservableObject {
    @Published var selectedTimeControl: TimeControl
    @Published var customMinutes: Int = 10
    @Published var customIncrement: Int = 0
    @Published var whiteOddsMinutes: String = ""
    @Published var whiteOddsSeconds: String = ""
    @Published var blackOddsMinutes: String = ""
    @Published var blackOddsSeconds: String = ""
    @Published var selectedOddsSide: PlayerSide = .black
    @Published var selectedClockColorPreset: ClockColorPreset = .green

    let sections: [TimeControlSection] = [
        TimeControlSection(
            name: .bullet,
            iconName: "hare.fill",
            iconColorName: "bulletAccent",
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
            iconName: "bolt.fill",
            iconColorName: "blitzAccent",
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
            iconName: "stopwatch.fill",
            iconColorName: "rapidAccent",
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
            iconName: "sun.max.fill",
            iconColorName: "dailyAccent",
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

    var effectiveSelection: TimeControl {
        selectedTimeControl.name == .custom ? customTimeControl : selectedTimeControl
    }

    func select(_ timeControl: TimeControl) {
        selectedTimeControl = timeControl
    }

    func selectCustom() {
        selectedTimeControl = customTimeControl
    }
}

struct TimeControlSection: Identifiable {
    var id: TimeControlName { name }

    let name: TimeControlName
    let iconName: String
    let iconColorName: String
    let options: [TimeControl]
}
