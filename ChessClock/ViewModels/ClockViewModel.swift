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

    private let increment: TimeInterval
    private var timer: AnyCancellable?
    private var lastTickDate: Date?

    init(timeControl: TimeControl) {
        let startingTime = TimeInterval(max(1, timeControl.totalSeconds))
        self.whiteRemaining = startingTime
        self.blackRemaining = startingTime
        self.increment = TimeInterval(max(0, timeControl.increment))
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
        let startingTime = TimeInterval(max(1, timeControl.totalSeconds))
        whiteRemaining = startingTime
        blackRemaining = startingTime
        activePlayer = nil
        state = .start
        lastTickDate = nil
    }

    func formattedTime(for player: PlayerSide) -> String {
        formattedTime(remaining: player == .white ? whiteRemaining : blackRemaining)
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
        guard increment > 0 else { return }
        switch player {
        case .white:
            whiteRemaining += increment
        case .black:
            blackRemaining += increment
        }
    }

    private func finish() {
        state = .finished
        timer?.cancel()
        timer = nil
        lastTickDate = nil
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

enum PlayerSide: String, CaseIterable, Identifiable {
    case white = "White"
    case black = "Black"

    var id: String { rawValue }

    var opponent: PlayerSide {
        self == .white ? .black : .white
    }
}
