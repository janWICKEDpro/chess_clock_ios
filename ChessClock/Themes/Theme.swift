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
}

class ThemeManager: ObservableObject {

    @Published var selectedTheme: ThemeProtocol = Main()
    
    func setTheme(_ theme: ThemeProtocol) {
        selectedTheme = theme
    }
}
