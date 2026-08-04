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
    @State private var route: AppRoute

    init() {
        if let snapshot = ActiveGamePersistence.load() {
            _route = State(initialValue: .clock(snapshot.timeControl, snapshot.colorPreset, snapshot))
        } else {
            _route = State(initialValue: .setup)
        }
    }

    var body: some View {
        Group {
            switch route {
            case .setup:
                HomeView(viewModel: setupViewModel) {
                    let timeControl = setupViewModel.effectiveSelection
                    let colorPreset = setupViewModel.selectedClockColorPreset
                    route = .clock(
                        timeControl,
                        colorPreset,
                        nil
                    )
                }
            case .clock(let timeControl, let colorPreset, let snapshot):
                ActiveClockView(
                    timeControl: timeControl,
                    colorPreset: colorPreset,
                    initialSnapshot: snapshot
                ) { snapshot in
                    ActiveGamePersistence.save(snapshot)
                    route = .clock(snapshot.timeControl, snapshot.colorPreset, snapshot)
                } onExit: {
                    ActiveGamePersistence.clear()
                    route = .setup
                }
            }
        }
        .preferredColorScheme(theme.colorScheme)
    }
}

private enum AppRoute: Equatable {
    case setup
    case clock(TimeControl, ClockColorPreset, ActiveGameSnapshot?)
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
