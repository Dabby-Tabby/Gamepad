//
//  LiquidGlassButtonStyle.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI

@available(iOS 26.0, *)
struct LiquidGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.system(size: 30, weight: .bold))
            .frame(width: 80, height: 80)
            .glassEffect(.clear, in: Circle())
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6),
                       value: configuration.isPressed)
    }
}
