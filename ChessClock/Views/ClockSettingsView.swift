//
//  ClockSettingsView.swift
//  ChessClock
//
//  Created by Codex on 04/08/2026.
//

import SwiftUI

struct ClockSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    @Binding var selectedPreset: ClockColorPreset

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Active Clock Colours")
                        .font(theme.selectedTheme.textTitleFont)
                        .fontWeight(.bold)
                        .foregroundStyle(theme.selectedTheme.bodyTextColor)

                    VStack(spacing: 12) {
                        ForEach(ClockColorPreset.allCases) { preset in
                            ClockColorPresetRow(
                                preset: preset,
                                isSelected: preset == selectedPreset
                            ) {
                                selectedPreset = preset
                            }
                        }
                    }

                    InactiveClockPreview()
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 24)
            }
            .background(theme.selectedTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(theme.selectedTheme.boldBodyTextFont)
                }
            }
        }
    }
}

private struct ClockColorPresetRow: View {
    @EnvironmentObject private var theme: ThemeManager
    let preset: ClockColorPreset
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ClockPresetSwatches(preset: preset)

                Text(preset.title)
                    .font(theme.selectedTheme.boldBodyTextFont)
                    .foregroundStyle(theme.selectedTheme.bodyTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? theme.selectedTheme.primaryColor : theme.selectedTheme.secondaryTextColor)
            }
            .padding(16)
            .background(theme.selectedTheme.surfaceColor)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? theme.selectedTheme.primaryColor : .clear, lineWidth: 2)
            }
            .clipShape(.rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(preset.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct ClockPresetSwatches: View {
    let preset: ClockColorPreset

    var body: some View {
        HStack(spacing: 0) {
            preset.activeColor(for: .white)
            preset.activeColor(for: .black)
        }
        .frame(width: 58, height: 38)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 8))
        .accessibilityHidden(true)
    }
}

private struct InactiveClockPreview: View {
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.selectedTheme.inactiveClockColor)
                .frame(width: 58, height: 38)

            Text("Inactive Clock")
                .font(theme.selectedTheme.boldBodyTextFont)
                .foregroundStyle(theme.selectedTheme.secondaryTextColor)
        }
        .padding(.top, 10)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ClockSettingsView(selectedPreset: .constant(.green))
        .environmentObject(ThemeManager())
}
