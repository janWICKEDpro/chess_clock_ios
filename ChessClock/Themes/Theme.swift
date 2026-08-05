//
//  Theme.swift
//  ChessClock
//
//  Created by Jan Royal on 27/12/2025.
//

//Credits to https://medium.com/@katramesh91/effortless-theming-in-swiftui-mastering-multiple-themes-and-best-practices-061113be6d3d
//for this way Theming strategy

import Foundation
import SwiftUI
import Combine

protocol ThemeProtocol {
    var largeTitleFont: Font { get }
    var textTitleFont: Font { get }
    var bodyTextFont: Font { get }
    var boldBodyTextFont: Font { get }
    var captionTxtFont: Font { get }
    
    var backgroundColor: Color { get }
    var surfaceColor: Color { get }
    var primaryColor: Color { get }
    var dividerColor: Color { get }
    var bodyTextColor: Color { get }
    var secondaryTextColor: Color { get }
    var fieldColor: Color { get }
    var successColor: Color { get }
    var warningColor: Color { get }
    var criticalColor: Color { get }
    var inactiveClockColor: Color { get }
}

struct Main: ThemeProtocol {
    var largeTitleFont: Font = .custom("DMMono-Medium", size: 30.0)
    var textTitleFont: Font = .custom("DMMono-Medium", size: 24.0)
    var bodyTextFont: Font = .custom("DMMono-Regular", size: 14.0)
    var boldBodyTextFont: Font = .custom("DMMono-Medium", size: 14.0)
    var captionTxtFont: Font = .custom("DMMono-Regular", size: 12.0)
    
    var backgroundColor: Color { return Color("backgroundColor") }
    var surfaceColor: Color { return Color("surfaceColor") }
    var primaryColor: Color { return Color("primaryColor") }
    var dividerColor: Color { return Color("dividerColor") }
    var bodyTextColor: Color { return Color("textColor") }
    var secondaryTextColor: Color { return Color("secondaryTextColor") }
    var fieldColor: Color { return Color("fieldColor") }
    var successColor: Color { return Color("successColor") }
    var warningColor: Color { return Color("warningColor") }
    var criticalColor: Color { return Color("criticalColor") }
    var inactiveClockColor: Color { return Color("inactiveClockColor") }
}

class ThemeManager: ObservableObject {
    private static let colorSchemeStorageKey = "selectedColorScheme"

    @Published var selectedTheme: ThemeProtocol = Main()
    @Published var colorScheme: ColorScheme {
        didSet {
            UserDefaults.standard.set(colorScheme.storageValue, forKey: Self.colorSchemeStorageKey)
        }
    }

    init() {
        colorScheme = Self.savedColorScheme()
    }
    
    var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    func setTheme(_ theme: ThemeProtocol) {
        selectedTheme = theme
    }
    
    func toggleColorScheme() {
        colorScheme = colorScheme == .dark ? .light : .dark
    }

    private static func savedColorScheme() -> ColorScheme {
        guard let storedValue = UserDefaults.standard.string(forKey: colorSchemeStorageKey) else { return .light }
        return ColorScheme(storageValue: storedValue) ?? .light
    }
}

private extension ColorScheme {
    init?(storageValue: String) {
        switch storageValue {
        case "light":
            self = .light
        case "dark":
            self = .dark
        default:
            return nil
        }
    }

    var storageValue: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "light"
        }
    }
}
