//
//  Thememanager .swift
//  GYM
//
//  Created by Mohamed ahmed on 13/09/2026.
//



import SwiftUI
import Combine
import UIKit

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"

    var uiStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var arabicName: String {
        switch self {
        case .system: return "تلقائي"
        case .light:  return "فاتح"
        case .dark:   return "داكن"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .system: return .secondary
        case .light:  return .orange
        case .dark:   return .indigo
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var current: AppTheme

    init() {
        let saved = UserDefaults.standard.string(forKey: "appTheme") ?? AppTheme.system.rawValue
        self.current = AppTheme(rawValue: saved) ?? .system
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ThemeManager.apply(AppTheme(rawValue: saved) ?? .system)
        }
    }

    func set(_ theme: AppTheme) {
        current = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
        ThemeManager.apply(theme)
    }

    static func apply(_ theme: AppTheme) {
        DispatchQueue.main.async {
            for scene in UIApplication.shared.connectedScenes {
                guard let ws = scene as? UIWindowScene else { continue }
                for window in ws.windows {
                    window.overrideUserInterfaceStyle = theme.uiStyle
                }
            }
        }
    }
}
