//
//  ContentView.swift
//  ChessClock
//
//  Created by Jan Royal on 26/12/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var theme: ThemeManager
    @StateObject private var setupViewModel = SetupViewModel()
    @State private var route: AppRoute = .setup

    var body: some View {
        Group {
            switch route {
            case .setup:
                HomeView(viewModel: setupViewModel) {
                    route = .clock(
                        setupViewModel.effectiveSelection,
                        setupViewModel.selectedClockColorPreset
                    )
                }
            case .clock(let timeControl, let colorPreset):
                ActiveClockView(timeControl: timeControl, colorPreset: colorPreset) {
                    route = .setup
                }
            }
        }
        .preferredColorScheme(theme.colorScheme)
    }
}

private enum AppRoute: Equatable {
    case setup
    case clock(TimeControl, ClockColorPreset)
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
