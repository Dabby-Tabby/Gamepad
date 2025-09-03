//
//  LiquidCapsuleButtonStyle.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI

// MARK: - Overview
// A lightweight button style that provides tactile feedback via scale/opacity
// when the Button is pressed. This is visual only; key events are produced by gestures.

@available(iOS 26.0, *)
struct LiquidCapsuleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6),
                       value: configuration.isPressed)
    }
}
