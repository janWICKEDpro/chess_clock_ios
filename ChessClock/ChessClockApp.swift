//
//  ChessClockApp.swift
//  ChessClock
//
//  Created by Jan Royal on 26/12/2025.
//

import SwiftUI

@main
struct ChessClockApp: App {
    @StateObject private var theme: ThemeManager = ThemeManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
        }
    }
}
