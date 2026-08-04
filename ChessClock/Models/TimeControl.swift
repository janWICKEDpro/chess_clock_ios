//
//  File.swift
//  ChessClock
//
//  Created by Jan Royal on 26/12/2025.
//

import Foundation

struct TimeControl: Identifiable, Equatable {
    var id: String { label }

    let name: TimeControlName
    let minutes: Int
    let seconds: Int
    let increment: Int
    let label: String
    let advanced: Bool
    let whiteStartingSeconds: Int?
    let blackStartingSeconds: Int?

    init(
        name: TimeControlName,
        minutes: Int,
        seconds: Int,
        increment: Int,
        label: String,
        advanced: Bool,
        whiteStartingSeconds: Int? = nil,
        blackStartingSeconds: Int? = nil
    ) {
        self.name = name
        self.minutes = minutes
        self.seconds = seconds
        self.increment = increment
        self.label = label
        self.advanced = advanced
        self.whiteStartingSeconds = whiteStartingSeconds
        self.blackStartingSeconds = blackStartingSeconds
    }

    var totalSeconds: Int {
        minutes * 60 + seconds
    }

    var whiteTotalSeconds: Int {
        whiteStartingSeconds ?? totalSeconds
    }

    var blackTotalSeconds: Int {
        blackStartingSeconds ?? totalSeconds
    }
}
