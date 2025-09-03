//
//  Color+Hex.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI

// MARK: - Overview
// Convenience initializer for converting a hex string (e.g., "#FFAA00") into a SwiftUI Color.
// Non-6-digit inputs default to black.

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        if hex.count == 6 {
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        } else {
            r = 0; g = 0; b = 0
        }
        self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255)
    }
}
