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
                    route = .clock(setupViewModel.effectiveSelection)
                }
            case .clock(let timeControl):
                ActiveClockView(timeControl: timeControl) {
                    route = .setup
                }
            }
        }
        .preferredColorScheme(theme.colorScheme)
    }
}

private enum AppRoute: Equatable {
    case setup
    case clock(TimeControl)
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
