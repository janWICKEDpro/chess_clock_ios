//
//  HomeView.swift
//  ChessClock
//
//  Created by Jan Royal on 15/02/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var theme: ThemeManager
    @ObservedObject var viewModel: SetupViewModel
    @State private var presentedSheet: SetupSheet?
    @State private var showsMoreTimeControls = false

    let onStartGame: () -> Void

    var body: some View {
        ZStack {
            theme.selectedTheme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 34) {
                    SetupHeader {
                        presentedSheet = .settings
                    }

                    ForEach(visibleSections) { section in
                        TimeControlSectionView(
                            section: section,
                            selectedTimeControl: viewModel.selectedTimeControl,
                            onSelect: viewModel.select
                        )
                    }

                    if showsMoreTimeControls {
                        TimeOddsView(
                            summary: viewModel.oddsSelectionLabel,
                            isSelected: viewModel.selectedTimeControl.name == .odds,
                            onConfigure: {
                                viewModel.seedOddsFieldsIfNeeded()
                                presentedSheet = .timeOdds
                            }
                        )

                        CustomTimeControlView(
                            minutes: $viewModel.customMinutes,
                            increment: $viewModel.customIncrement,
                            isSelected: viewModel.selectedTimeControl.name == .custom
                        ) {
                            viewModel.selectCustom()
                        }
                    }

                    MoreTimeControlsButton(
                        showsMoreTimeControls: showsMoreTimeControls,
                        onToggleMore: toggleMoreTimeControls
                    )
                }
                .padding(.horizontal, 22)
                .padding(.top, 52)
                .padding(.bottom, 118)
                .animation(.snappy, value: showsMoreTimeControls)
            }
        }
        .safeAreaInset(edge: .bottom) {
            BottomStartBar(
                selection: viewModel.effectiveSelection,
                onStartGame: onStartGame
            )
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .settings:
                ClockSettingsView(selectedPreset: $viewModel.selectedClockColorPreset)
                    .environmentObject(theme)
            case .timeOdds:
                TimeOddsSheetView(viewModel: viewModel)
                    .environmentObject(theme)
            }
        }
    }

    private var visibleSections: [TimeControlSection] {
        viewModel.sections.filter { section in
            showsMoreTimeControls || section.name == .bullet || section.name == .blitz || section.name == .rapid
        }
    }

    private func toggleMoreTimeControls() {
        withAnimation(.snappy) {
            showsMoreTimeControls.toggle()
            if !showsMoreTimeControls {
                viewModel.resetHiddenSelectionIfNeeded()
            }
        }
    }
}

private enum SetupSheet: Identifiable {
    case settings
    case timeOdds

    var id: String {
        switch self {
        case .settings:
            return "settings"
        case .timeOdds:
            return "timeOdds"
        }
    }
}

private struct MoreTimeControlsButton: View {
    @EnvironmentObject private var theme: ThemeManager
    let showsMoreTimeControls: Bool
    let onToggleMore: () -> Void

    var body: some View {
        Button(action: onToggleMore) {
            HStack(spacing: 8) {
                Text(showsMoreTimeControls ? "Fewer Time Controls" : "More Time Controls")
                    .font(theme.selectedTheme.boldBodyTextFont)

                Image(systemName: showsMoreTimeControls ? "chevron.up" : "chevron.down")
                    .font(theme.selectedTheme.captionTxtFont)
                    .fontWeight(.bold)
            }
            .foregroundStyle(theme.selectedTheme.secondaryTextColor)
            .frame(maxWidth: .infinity)
            .frame(height: 34)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showsMoreTimeControls ? "Show fewer time controls" : "Show more time controls")
    }
}

private struct SetupHeader: View {
    @EnvironmentObject private var theme: ThemeManager
    let onShowSettings: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Text("Time Controls")
                .font(theme.selectedTheme.textTitleFont)
                .fontWeight(.bold)
                .foregroundStyle(theme.selectedTheme.bodyTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()

            Button(action: onShowSettings) {
                Image(systemName: "paintpalette.fill")
                    .font(.title3)
                    .foregroundStyle(theme.selectedTheme.secondaryTextColor)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open clock color settings")

            Button {
                theme.toggleColorScheme()
            } label: {
                Image(systemName: theme.isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                    .font(.title2)
                    .foregroundStyle(Color("dailyAccent"))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(theme.isDarkMode ? "Switch to light mode" : "Switch to dark mode")
        }
    }
}

private struct TimeControlSectionView: View {
    let section: TimeControlSection
    let selectedTimeControl: TimeControl
    let onSelect: (TimeControl) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 11),
        GridItem(.flexible(), spacing: 11),
        GridItem(.flexible(), spacing: 11)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionTitle(
                title: section.name.rawValue,
                showsInfo: section.name == .daily
            )

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(section.options) { option in
                    TimeControlOptionView(
                        timeControl: option,
                        onTap: onSelect,
                        isSelected: option == selectedTimeControl
                    )
                    .gridCellColumns(option.advanced ? 2 : 1)
                }
            }
        }
    }
}

private struct SectionTitle: View {
    @EnvironmentObject private var theme: ThemeManager
    let title: String
    var showsInfo = false

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(theme.selectedTheme.textTitleFont)
                .fontWeight(.bold)
                .foregroundStyle(theme.selectedTheme.bodyTextColor)

            if showsInfo {
                Image(systemName: "info.circle.fill")
                    .font(.caption)
                    .foregroundStyle(theme.selectedTheme.secondaryTextColor)
                    .accessibilityLabel("Daily time controls information")
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct TimeOddsView: View {
    @EnvironmentObject private var theme: ThemeManager
    let summary: String
    let isSelected: Bool
    let onConfigure: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionTitle(
                title: "Time Odds"
            )

            Button(action: onConfigure) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(isSelected ? "Time Odds Selected" : "Configure Time Odds")
                            .font(theme.selectedTheme.boldBodyTextFont)
                            .foregroundStyle(theme.selectedTheme.bodyTextColor)

                        Text(summary)
                            .font(theme.selectedTheme.captionTxtFont)
                            .foregroundStyle(theme.selectedTheme.secondaryTextColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundStyle(theme.selectedTheme.secondaryTextColor)
                }
                .padding(18)
                .frame(maxWidth: .infinity)
                .background(theme.selectedTheme.surfaceColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? theme.selectedTheme.primaryColor : .clear, lineWidth: 2)
                }
                .clipShape(.rect(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isSelected ? "Edit selected time odds" : "Configure time odds")
            .accessibilityValue(summary)
        }
    }
}

private struct CustomTimeControlView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Binding var minutes: Int
    @Binding var increment: Int
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionTitle(
                title: "Custom"
            )

            HStack(spacing: 11) {
                StepperTile(title: "min", value: $minutes, range: 0...180)
                StepperTile(title: "inc", value: $increment, range: 0...60)

                Button(action: onSelect) {
                    Image(systemName: "arrow.right")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(theme.selectedTheme.bodyTextColor)
                        .frame(width: 68, height: 62)
                        .background(theme.selectedTheme.surfaceColor)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? theme.selectedTheme.primaryColor : .clear, lineWidth: 2)
                        }
                        .clipShape(.rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select custom time control")
            }
        }
    }
}

private struct BottomStartBar: View {
    @EnvironmentObject private var theme: ThemeManager
    let selection: TimeControl
    let onStartGame: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Capsule()
                .fill(theme.selectedTheme.dividerColor)
                .frame(width: 42, height: 4)
                .padding(.top, 8)
                .accessibilityHidden(true)

            Button(action: onStartGame) {
                Text("Start Game")
                    .font(theme.selectedTheme.textTitleFont)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                    .background(theme.selectedTheme.primaryColor)
                    .clipShape(.rect(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start game with \(selection.label)")
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 10)
        .background {
            theme.selectedTheme.backgroundColor
                .overlay(alignment: .top) {
                    theme.selectedTheme.dividerColor.frame(height: 1)
                }
                .ignoresSafeArea()
        }
    }
}

#Preview {
    HomeView(viewModel: SetupViewModel()) {}
        .environmentObject(ThemeManager())
}
