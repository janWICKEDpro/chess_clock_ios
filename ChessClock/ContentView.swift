//
//  ContentView.swift
//  ChessClock
//
//  Created by Jan Royal on 26/12/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var theme: ThemeManager
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .font(theme.selectedTheme.textTitleFont.weight(.bold))
                .foregroundStyle(theme.selectedTheme.primaryColor)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
