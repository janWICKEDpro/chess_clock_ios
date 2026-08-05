//
//  ClockColorPreset.swift
//  ChessClock
//
//  Created by Codex on 04/08/2026.
//

import SwiftUI

enum ClockColorPreset: String, CaseIterable, Identifiable, Equatable, Codable {
    case green
    case whiteBlack
    case blueRed
    case amberPurple

    var id: String { rawValue }

    var title: String {
        switch self {
        case .green:
            return "Classic Green"
        case .whiteBlack:
            return "White / Dark"
        case .blueRed:
            return "Blue / Red"
        case .amberPurple:
            return "Amber / Purple"
        }
    }

    func activeColor(for side: PlayerSide) -> Color {
        switch self {
        case .green:
            return Color("successColor")
        case .whiteBlack:
            return side == .white ? Color("playerLight") : .chessClockBlack
        case .blueRed:
            return side == .white ? Color(red: 0.07, green: 0.36, blue: 0.93) : Color("criticalColor")
        case .amberPurple:
            return side == .white ? Color("warningColor") : Color("oddsAccent")
        }
    }

    func activeTextColor(for side: PlayerSide) -> Color {
        switch self {
        case .whiteBlack:
            return side == .white ? .chessClockBlack : .white
        case .amberPurple:
            return .white
        case .green, .blueRed:
            return .white
        }
    }

    func activeSecondaryTextColor(for side: PlayerSide) -> Color {
        activeTextColor(for: side).opacity(0.84)
    }
}

extension Color {
    static let chessClockBlack = Color(red: 0, green: 0, blue: 0)
}
