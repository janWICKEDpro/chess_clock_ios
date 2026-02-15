//
//  HomeView.swift
//  ChessClock
//
//  Created by Jan Royal on 15/02/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var theme: ThemeManager
    var body: some View {
        ZStack {
            theme.selectedTheme.backgroundColor
            VStack {
                HStack {
                    Text("Time Controls")
                        .font(theme.selectedTheme.textTitleFont)
                        .foregroundStyle(theme.selectedTheme.bodyTextColor)
                    Spacer()
                    Image(systemName: "sun.max")
                        .foregroundStyle(theme.selectedTheme.primaryColor)
                }
                ScrollView {
                    ForEach(0..<1000) { i in
                        Text("\(i)")
                    }
                }
            }.padding(16)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ThemeManager())
}
