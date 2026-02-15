//
//  TimeControlOptionView.swift
//  ChessClock
//
//  Created by Jan Royal on 15/02/2026.
//

import SwiftUI

struct TimeControlOptionView: View {
    @EnvironmentObject private var theme: ThemeManager
    let timeControl: TimeControl
    let onTap: (TimeControl) -> Void
    let isSelected: Bool
    var body: some View {
        Button(action: {
            onTap(timeControl)
        }, label: {
            HStack {
                Spacer()
                Text(timeControl.label)
                    .font(theme.selectedTheme.boldBodyTextFont.bold())
                    .foregroundColor(theme.selectedTheme.bodyTextColor)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(theme.selectedTheme.surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        ).overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .foregroundStyle(theme.selectedTheme.primaryColor)
                .opacity(isSelected ? 1 : 0)
        )
    }
}

#Preview {
    TimeControlOptionView(
        timeControl: TimeControl(
            name: .blitz,
            minutes: 3,
            seconds: 0,
            increment: 1,
            label: "3 | 2",
            advanced: false
        ),
        onTap: { _ in
            
        },
        isSelected: true
        
    )
    .environmentObject(ThemeManager())
}
