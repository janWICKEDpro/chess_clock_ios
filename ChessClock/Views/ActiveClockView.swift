//
//  ActiveClockView.swift
//  ChessClock
//
//  Created by Codex on 04/08/2026.
//

import SwiftUI
import UIKit

struct ActiveClockView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: ClockViewModel
    @State private var isShowingExitConfirmation = false

    let timeControl: TimeControl
    let colorPreset: ClockColorPreset
    let onPersistenceUpdate: (ActiveGameSnapshot) -> Void
    let onExit: () -> Void

    init(
        timeControl: TimeControl,
        colorPreset: ClockColorPreset,
        initialSnapshot: ActiveGameSnapshot? = nil,
        onPersistenceUpdate: @escaping (ActiveGameSnapshot) -> Void = { _ in },
        onExit: @escaping () -> Void
    ) {
        self.timeControl = timeControl
        self.colorPreset = colorPreset
        self.onPersistenceUpdate = onPersistenceUpdate
        self.onExit = onExit
        _viewModel = StateObject(wrappedValue: ClockViewModel(timeControl: timeControl, snapshot: initialSnapshot))
    }

    var body: some View {
        VStack(spacing: 0) {
            PlayerClockPanel(
                side: .black,
                timeText: viewModel.formattedTime(for: .black),
                isActive: viewModel.activePlayer == .black,
                isFinished: viewModel.state == .finished && viewModel.blackRemaining == 0,
                colorPreset: colorPreset
            ) {
                handleClockTap(for: .black)
            }
            .rotationEffect(.degrees(180))

            GameControlBar(
                state: viewModel.state,
                timeControlLabel: timeControl.label,
                onPauseResume: handlePauseResume,
                onExit: {
                    ClockHaptics.controlTap()
                    isShowingExitConfirmation = true
                }
            )

            PlayerClockPanel(
                side: .white,
                timeText: viewModel.formattedTime(for: .white),
                isActive: viewModel.activePlayer == .white,
                isFinished: viewModel.state == .finished && viewModel.whiteRemaining == 0,
                colorPreset: colorPreset
            ) {
                handleClockTap(for: .white)
            }
        }
        .background(theme.selectedTheme.backgroundColor.ignoresSafeArea())
        .onAppear {
            persistClockSnapshot()
        }
        .onChange(of: scenePhase) { phase in
            guard phase != .active else { return }
            persistClockSnapshot()
        }
        .confirmationDialog("Leave game?", isPresented: $isShowingExitConfirmation) {
            Button("Leave Game", role: .destructive, action: onExit)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The current clock state will be discarded.")
        }
    }

    private func handlePauseResume() {
        ClockHaptics.controlTap()

        switch viewModel.state {
        case .start:
            viewModel.start(with: .white)
        case .inProgress:
            viewModel.pause()
        case .paused:
            viewModel.resume()
        case .finished:
            viewModel.reset(to: timeControl)
        }

        persistClockSnapshot()
    }

    private func handleClockTap(for player: PlayerSide) {
        guard viewModel.tapClock(for: player) else { return }
        ClockHaptics.clockTap()
        persistClockSnapshot()
    }

    private func persistClockSnapshot() {
        onPersistenceUpdate(viewModel.snapshot(for: timeControl, colorPreset: colorPreset))
    }
}

private enum ClockHaptics {
    static func clockTap() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    static func controlTap() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

private struct PlayerClockPanel: View {
    @EnvironmentObject private var theme: ThemeManager
    let side: PlayerSide
    let timeText: String
    let isActive: Bool
    let isFinished: Bool
    let colorPreset: ClockColorPreset
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Label(side.rawValue, systemImage: side == .white ? "circle" : "circle.fill")
                        .font(theme.selectedTheme.boldBodyTextFont)
                        .foregroundStyle(labelColor)
                    Spacer()
                    Text(isActive ? "TURN" : "WAIT")
                        .font(theme.selectedTheme.captionTxtFont)
                        .fontWeight(.bold)
                        .foregroundStyle(labelColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(labelColor.opacity(0.15))
                        .clipShape(.capsule)
                }

                Spacer(minLength: 12)

                Text(timeText)
                    .font(.custom("DMMono-Medium", size: 58, relativeTo: .largeTitle))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .foregroundStyle(timeColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(isFinished ? "Time expired" : "Tap after your move")
                    .font(theme.selectedTheme.bodyTextFont)
                    .foregroundStyle(labelColor)
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(panelColor)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(side.rawValue) clock")
        .accessibilityValue(timeText)
        .accessibilityHint("Tap after \(side.rawValue)'s move")
    }

    private var panelColor: Color {
        if isFinished {
            return theme.selectedTheme.criticalColor
        }

        if isActive {
            return colorPreset.activeColor(for: side)
        }

        return theme.selectedTheme.inactiveClockColor
    }

    private var timeColor: Color {
        if isFinished {
            return .white
        }

        if isActive {
            return colorPreset.activeTextColor(for: side)
        }

        return theme.selectedTheme.secondaryTextColor
    }

    private var labelColor: Color {
        if isFinished {
            return .white.opacity(0.86)
        }

        if isActive {
            return colorPreset.activeSecondaryTextColor(for: side)
        }

        return theme.selectedTheme.secondaryTextColor
    }
}

private struct GameControlBar: View {
    @EnvironmentObject private var theme: ThemeManager
    let state: ClockState
    let timeControlLabel: String
    let onPauseResume: () -> Void
    let onExit: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onExit) {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundStyle(theme.selectedTheme.bodyTextColor)
                    .frame(width: 48, height: 48)
                    .background(theme.selectedTheme.backgroundColor)
                    .clipShape(.circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Exit game")

            VStack(spacing: 3) {
                Text(timeControlLabel)
                    .font(theme.selectedTheme.boldBodyTextFont)
                    .foregroundStyle(theme.selectedTheme.bodyTextColor)
                Text(statusText)
                    .font(theme.selectedTheme.captionTxtFont)
                    .foregroundStyle(theme.selectedTheme.secondaryTextColor)
            }
            .frame(maxWidth: .infinity)

            Button(action: onPauseResume) {
                Image(systemName: controlIcon)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(theme.selectedTheme.primaryColor)
                    .clipShape(.circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(controlLabel)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(theme.selectedTheme.backgroundColor)
    }

    private var statusText: String {
        switch state {
        case .start:
            return "Ready"
        case .inProgress:
            return "Running"
        case .paused:
            return "Paused"
        case .finished:
            return "Finished"
        }
    }

    private var controlIcon: String {
        switch state {
        case .start, .paused:
            return "play.fill"
        case .inProgress:
            return "pause.fill"
        case .finished:
            return "arrow.clockwise"
        }
    }

    private var controlLabel: String {
        switch state {
        case .start:
            return "Start clock"
        case .inProgress:
            return "Pause clock"
        case .paused:
            return "Resume clock"
        case .finished:
            return "Reset clock"
        }
    }
}

#Preview {
    ActiveClockView(
        timeControl: TimeControl(name: .blitz, minutes: 3, seconds: 0, increment: 2, label: "3 | 2", advanced: false),
        colorPreset: .green,
        onExit: {}
    )
    .environmentObject(ThemeManager())
}
