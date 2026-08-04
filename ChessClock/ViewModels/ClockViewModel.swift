//
//  ClockViewModel.swift
//  ChessClock
//
//  Created by Jan Royal on 26/12/2025.
//

import Foundation
import Combine

final class ClockViewModel: ObservableObject {
    @Published private(set) var whiteRemaining: TimeInterval
    @Published private(set) var blackRemaining: TimeInterval
    @Published private(set) var activePlayer: PlayerSide?
    @Published private(set) var state: ClockState = .start

    private let whiteIncrement: TimeInterval
    private let blackIncrement: TimeInterval
    private var timer: AnyCancellable?
    private var lastTickDate: Date?

    init(timeControl: TimeControl, snapshot: ActiveGameSnapshot? = nil) {
        self.whiteRemaining = TimeInterval(max(1, timeControl.whiteTotalSeconds))
        self.blackRemaining = TimeInterval(max(1, timeControl.blackTotalSeconds))
        self.whiteIncrement = TimeInterval(max(0, timeControl.whiteIncrement))
        self.blackIncrement = TimeInterval(max(0, timeControl.blackIncrement))

        if let snapshot {
            restore(from: snapshot)
        }

        if state == .inProgress {
            lastTickDate = Date()
            startTimer()
        }
    }

    deinit {
        timer?.cancel()
    }

    func start(with player: PlayerSide) {
        guard state != .finished else { return }
        activePlayer = player
        state = .inProgress
        lastTickDate = Date()
        startTimer()
    }

    func tapClock(for player: PlayerSide) {
        if state == .start {
            start(with: player.opponent)
            return
        }

        guard state == .inProgress, activePlayer == player else { return }
        addIncrement(to: player)
        activePlayer = player.opponent
        lastTickDate = Date()
    }

    func pause() {
        guard state == .inProgress else { return }
        state = .paused
        timer?.cancel()
        timer = nil
        lastTickDate = nil
    }

    func resume() {
        guard state == .paused else { return }
        state = .inProgress
        lastTickDate = Date()
        startTimer()
    }

    func reset(to timeControl: TimeControl) {
        timer?.cancel()
        timer = nil
        whiteRemaining = TimeInterval(max(1, timeControl.whiteTotalSeconds))
        blackRemaining = TimeInterval(max(1, timeControl.blackTotalSeconds))
        activePlayer = nil
        state = .start
        lastTickDate = nil
    }

    func formattedTime(for player: PlayerSide) -> String {
        formattedTime(remaining: player == .white ? whiteRemaining : blackRemaining)
    }

    func snapshot(for timeControl: TimeControl, colorPreset: ClockColorPreset, at date: Date = Date()) -> ActiveGameSnapshot {
        let adjusted = adjustedClockValues(at: date)

        return ActiveGameSnapshot(
            timeControl: timeControl,
            colorPreset: colorPreset,
            whiteRemaining: adjusted.whiteRemaining,
            blackRemaining: adjusted.blackRemaining,
            activePlayer: adjusted.activePlayer,
            state: adjusted.state,
            persistedAt: date
        )
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.tick(at: date)
            }
    }

    private func tick(at date: Date) {
        guard state == .inProgress, let activePlayer else { return }
        let elapsed = date.timeIntervalSince(lastTickDate ?? date)
        lastTickDate = date

        switch activePlayer {
        case .white:
            whiteRemaining = max(0, whiteRemaining - elapsed)
            if whiteRemaining == 0 { finish() }
        case .black:
            blackRemaining = max(0, blackRemaining - elapsed)
            if blackRemaining == 0 { finish() }
        }
    }

    private func addIncrement(to player: PlayerSide) {
        switch player {
        case .white:
            guard whiteIncrement > 0 else { return }
            whiteRemaining += whiteIncrement
        case .black:
            guard blackIncrement > 0 else { return }
            blackRemaining += blackIncrement
        }
    }

    private func finish() {
        state = .finished
        timer?.cancel()
        timer = nil
        lastTickDate = nil
    }

    private func restore(from snapshot: ActiveGameSnapshot) {
        let restored = Self.restoredClockValues(from: snapshot, at: Date())
        whiteRemaining = restored.whiteRemaining
        blackRemaining = restored.blackRemaining
        activePlayer = restored.activePlayer
        state = restored.state
    }

    private func adjustedClockValues(at date: Date) -> ActiveGameSnapshot.ClockValues {
        Self.adjustedClockValues(
            whiteRemaining: whiteRemaining,
            blackRemaining: blackRemaining,
            activePlayer: activePlayer,
            state: state,
            elapsed: lastTickDate.map { date.timeIntervalSince($0) } ?? 0
        )
    }

    private static func restoredClockValues(from snapshot: ActiveGameSnapshot, at date: Date) -> ActiveGameSnapshot.ClockValues {
        adjustedClockValues(
            whiteRemaining: snapshot.whiteRemaining,
            blackRemaining: snapshot.blackRemaining,
            activePlayer: snapshot.activePlayer,
            state: snapshot.state,
            elapsed: date.timeIntervalSince(snapshot.persistedAt)
        )
    }

    private static func adjustedClockValues(
        whiteRemaining: TimeInterval,
        blackRemaining: TimeInterval,
        activePlayer: PlayerSide?,
        state: ClockState,
        elapsed: TimeInterval
    ) -> ActiveGameSnapshot.ClockValues {
        var adjustedWhite = whiteRemaining
        var adjustedBlack = blackRemaining
        var adjustedState = state

        if state == .inProgress, let activePlayer {
            switch activePlayer {
            case .white:
                adjustedWhite = max(0, adjustedWhite - max(0, elapsed))
            case .black:
                adjustedBlack = max(0, adjustedBlack - max(0, elapsed))
            }

            if adjustedWhite == 0 || adjustedBlack == 0 {
                adjustedState = .finished
            }
        }

        return ActiveGameSnapshot.ClockValues(
            whiteRemaining: adjustedWhite,
            blackRemaining: adjustedBlack,
            activePlayer: activePlayer,
            state: adjustedState
        )
    }

    private func formattedTime(remaining: TimeInterval) -> String {
        let totalTenths = Int((remaining * 10).rounded(.up))
        let tenths = totalTenths % 10
        let totalSeconds = totalTenths / 10
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60

        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours):\(String(format: "%02d", remainingMinutes))"
        }

        if minutes == 0 && totalSeconds < 20 {
            return "\(seconds).\(tenths)"
        }

        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

enum PlayerSide: String, CaseIterable, Identifiable, Codable {
    case white = "White"
    case black = "Black"

    var id: String { rawValue }

    var opponent: PlayerSide {
        self == .white ? .black : .white
    }
}
