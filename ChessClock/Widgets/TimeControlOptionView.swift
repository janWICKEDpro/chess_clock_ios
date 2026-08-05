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
        Button {
            onTap(timeControl)
        } label: {
            Text(timeControl.label)
                .font(theme.selectedTheme.boldBodyTextFont)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .foregroundStyle(theme.selectedTheme.bodyTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 66)
                .background(theme.selectedTheme.surfaceColor)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? theme.selectedTheme.primaryColor : .clear, lineWidth: 2)
                }
                .clipShape(.rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(timeControl.name.rawValue), \(timeControl.label)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct SelectionField: View {
    @EnvironmentObject private var theme: ThemeManager
    let placeholder: String
    let height: CGFloat
    let usesProminentFont: Bool
    @Binding var value: String

    init(
        placeholder: String,
        value: Binding<String>,
        height: CGFloat = 52,
        usesProminentFont: Bool = false
    ) {
        self.placeholder = placeholder
        self._value = value
        self.height = height
        self.usesProminentFont = usesProminentFont
    }

    var body: some View {
        TextField(placeholder, text: $value)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(usesProminentFont ? theme.selectedTheme.textTitleFont : theme.selectedTheme.boldBodyTextFont)
            .fontWeight(.bold)
            .foregroundStyle(theme.selectedTheme.bodyTextColor)
            .padding(.horizontal, 12)
            .frame(height: height)
            .background(theme.selectedTheme.fieldColor)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.selectedTheme.dividerColor, lineWidth: 1)
            }
            .clipShape(.rect(cornerRadius: 8))
    }
}

struct StepperTile: View {
    @EnvironmentObject private var theme: ThemeManager
    let title: String
    let accessibilityTitle: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    init(title: String, accessibilityTitle: String? = nil, value: Binding<Int>, range: ClosedRange<Int>) {
        self.title = title
        self.accessibilityTitle = accessibilityTitle ?? title
        self._value = value
        self.range = range
    }

    var body: some View {
        Button {
            increment()
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(theme.selectedTheme.boldBodyTextFont)
                    .foregroundStyle(theme.selectedTheme.secondaryTextColor)

                Text("\(value)")
                    .font(theme.selectedTheme.boldBodyTextFont)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.selectedTheme.bodyTextColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .background(theme.selectedTheme.surfaceColor)
            .clipShape(.rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityTitle)
        .accessibilityValue("\(value)")
        .accessibilityHint("Tap to increase. Swipe up or down to adjust.")
        .accessibilityInputLabels([accessibilityTitle])
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                increment()
            case .decrement:
                decrement()
            @unknown default:
                break
            }
        }
    }

    private func increment() {
        value = value == range.upperBound ? range.lowerBound : value + 1
    }

    private func decrement() {
        value = value == range.lowerBound ? range.upperBound : value - 1
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
