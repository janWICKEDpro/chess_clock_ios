//
//  TimeOddsSheetView.swift
//  ChessClock
//
//  Created by Codex on 04/08/2026.
//

import SwiftUI

struct TimeOddsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    @ObservedObject var viewModel: SetupViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time Odds")
                            .font(theme.selectedTheme.textTitleFont)
                            .fontWeight(.bold)
                            .foregroundStyle(theme.selectedTheme.bodyTextColor)

                        Text(viewModel.oddsSelectionLabel)
                            .font(theme.selectedTheme.bodyTextFont)
                            .foregroundStyle(theme.selectedTheme.secondaryTextColor)
                    }

                    VStack(spacing: 16) {
                        OddsPlayerTimeEditor(
                            side: .white,
                            minutes: $viewModel.whiteOddsMinutes,
                            seconds: $viewModel.whiteOddsSeconds,
                            increment: $viewModel.whiteOddsIncrement
                        )

                        OddsPlayerTimeEditor(
                            side: .black,
                            minutes: $viewModel.blackOddsMinutes,
                            seconds: $viewModel.blackOddsSeconds,
                            increment: $viewModel.blackOddsIncrement
                        )
                    }

                    Button {
                        viewModel.selectOdds()
                        dismiss()
                    } label: {
                        Text("Use Time Odds")
                            .font(theme.selectedTheme.textTitleFont)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(theme.selectedTheme.primaryColor)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Use time odds")
                    .accessibilityValue(viewModel.oddsSelectionLabel)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 24)
            }
            .background(theme.selectedTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Configure Odds")
                        .font(theme.selectedTheme.boldBodyTextFont)
                        .foregroundStyle(theme.selectedTheme.bodyTextColor)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(theme.selectedTheme.boldBodyTextFont)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct OddsPlayerTimeEditor: View {
    @EnvironmentObject private var theme: ThemeManager
    let side: PlayerSide
    @Binding var minutes: String
    @Binding var seconds: String
    @Binding var increment: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                OddsPlayerBadge(side: side)

                Text(side.rawValue)
                    .font(theme.selectedTheme.boldBodyTextFont)
                    .foregroundStyle(theme.selectedTheme.bodyTextColor)
            }

            HStack(spacing: 12) {
                SelectionField(placeholder: "min", value: $minutes)
                    .accessibilityLabel("\(side.rawValue) odds minutes")

                SelectionField(placeholder: "sec", value: $seconds)
                    .accessibilityLabel("\(side.rawValue) odds seconds")
            }

            OddsIncrementControl(
                title: "\(side.rawValue) increment",
                increment: $increment
            )
        }
        .padding(18)
        .background(theme.selectedTheme.surfaceColor)
        .clipShape(.rect(cornerRadius: 10))
    }
}

private struct OddsPlayerBadge: View {
    let side: PlayerSide

    var body: some View {
        Circle()
            .fill(fillColor)
            .frame(width: 15, height: 15)
            .overlay {
                Circle()
                    .stroke(strokeColor, lineWidth: 1)
            }
            .accessibilityHidden(true)
    }

    private var fillColor: Color {
        side == .white ? Color("playerLight") : .chessClockBlack
    }

    private var strokeColor: Color {
        side == .white ? .chessClockBlack.opacity(0.24) : Color("playerLight").opacity(0.5)
    }
}

private struct OddsIncrementControl: View {
    @EnvironmentObject private var theme: ThemeManager
    let title: String
    @Binding var increment: Int
    private let range = 0...60

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Increment")
                .font(theme.selectedTheme.captionTxtFont)
                .fontWeight(.bold)
                .foregroundStyle(theme.selectedTheme.secondaryTextColor)

            HStack(spacing: 12) {
                Button {
                    decrement()
                } label: {
                    Image(systemName: "minus")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(decrementColor)
                        .frame(width: 56, height: 56)
                        .background(theme.selectedTheme.fieldColor)
                        .clipShape(.rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(increment == range.lowerBound)
                .accessibilityLabel("Decrease \(title)")

                VStack(spacing: 3) {
                    Text("\(increment)")
                        .font(theme.selectedTheme.textTitleFont)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(theme.selectedTheme.bodyTextColor)

                    Text("seconds")
                        .font(theme.selectedTheme.captionTxtFont)
                        .foregroundStyle(theme.selectedTheme.secondaryTextColor)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(theme.selectedTheme.fieldColor)
                .clipShape(.rect(cornerRadius: 8))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(title)
                .accessibilityValue("\(increment) seconds")

                Button {
                    incrementValue()
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(incrementColor)
                        .frame(width: 56, height: 56)
                        .background(theme.selectedTheme.fieldColor)
                        .clipShape(.rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(increment == range.upperBound)
                .accessibilityLabel("Increase \(title)")
            }
        }
    }

    private var decrementColor: Color {
        increment == range.lowerBound ? theme.selectedTheme.secondaryTextColor.opacity(0.35) : theme.selectedTheme.bodyTextColor
    }

    private var incrementColor: Color {
        increment == range.upperBound ? theme.selectedTheme.secondaryTextColor.opacity(0.35) : theme.selectedTheme.bodyTextColor
    }

    private func incrementValue() {
        increment = min(range.upperBound, increment + 1)
    }

    private func decrement() {
        increment = max(range.lowerBound, increment - 1)
    }
}

#Preview {
    TimeOddsSheetView(viewModel: SetupViewModel())
        .environmentObject(ThemeManager())
}
