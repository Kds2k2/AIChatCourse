//
//  Color+Hex.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 04.01.2026.
//

import SwiftUI

extension Color {
    
    // MARK: - HEX
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue, alpha: UInt64

        switch hex.count {
        case 6: // RGB (24-bit)
            (red, green, blue, alpha) = (
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF,
                0xFF
            )
        case 8: // RGBA (32-bit)
            (red, green, blue, alpha) = (
                (int >> 24) & 0xFF,
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )
        default:
            self = .clear
            return
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
    
    func toHex(alpha: Bool = false) -> String {
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alphaValue: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alphaValue) else {
            return alpha ? "#00000000" : "#000000"
        }

        if alpha {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                lroundf(Float(alphaValue) * 255),
                lroundf(Float(red) * 255),
                lroundf(Float(green) * 255),
                lroundf(Float(blue) * 255)
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(Float(red) * 255),
                lroundf(Float(green) * 255),
                lroundf(Float(blue) * 255)
            )
        }
    }
}
