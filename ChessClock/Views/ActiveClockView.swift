//
//  ActiveClockView.swift
//  ChessClock
//
//  Created by Codex on 04/08/2026.
//

import SwiftUI

struct ActiveClockView: View {
    @EnvironmentObject private var theme: ThemeManager
    @StateObject private var viewModel: ClockViewModel
    @State private var isShowingExitConfirmation = false

    let timeControl: TimeControl
    let onExit: () -> Void

    init(timeControl: TimeControl, onExit: @escaping () -> Void) {
        self.timeControl = timeControl
        self.onExit = onExit
        _viewModel = StateObject(wrappedValue: ClockViewModel(timeControl: timeControl))
    }

    var body: some View {
        VStack(spacing: 0) {
            PlayerClockPanel(
                side: .black,
                timeText: viewModel.formattedTime(for: .black),
                isActive: viewModel.activePlayer == .black,
                isFinished: viewModel.state == .finished && viewModel.blackRemaining == 0
            ) {
                viewModel.tapClock(for: .black)
            }
            .rotationEffect(.degrees(180))

            GameControlBar(
                state: viewModel.state,
                timeControlLabel: timeControl.label,
                onPauseResume: handlePauseResume,
                onExit: { isShowingExitConfirmation = true }
            )

            PlayerClockPanel(
                side: .white,
                timeText: viewModel.formattedTime(for: .white),
                isActive: viewModel.activePlayer == .white,
                isFinished: viewModel.state == .finished && viewModel.whiteRemaining == 0
            ) {
                viewModel.tapClock(for: .white)
            }
        }
        .background(theme.selectedTheme.backgroundColor.ignoresSafeArea())
        .confirmationDialog("Leave game?", isPresented: $isShowingExitConfirmation) {
            Button("Leave Game", role: .destructive, action: onExit)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The current clock state will be discarded.")
        }
    }

    private func handlePauseResume() {
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
    }
}

private struct PlayerClockPanel: View {
    @EnvironmentObject private var theme: ThemeManager
    let side: PlayerSide
    let timeText: String
    let isActive: Bool
    let isFinished: Bool
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
            return theme.selectedTheme.successColor
        }

        return theme.selectedTheme.surfaceColor
    }

    private var timeColor: Color {
        isActive || isFinished ? .white : theme.selectedTheme.bodyTextColor
    }

    private var labelColor: Color {
        isActive || isFinished ? .white.opacity(0.86) : theme.selectedTheme.secondaryTextColor
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
        onExit: {}
    )
    .environmentObject(ThemeManager())
}
