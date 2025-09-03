//
//  SelectStart.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI

// MARK: - Overview
// Provides small "glass" capsule buttons used for Select/Start controls and a square theme button.
// These controls emit explicit key down/up events using a DragGesture so we can model press/release
// semantics precisely (instead of relying on Button's action which only fires on release).

@available(iOS 26.0, *)
struct SelectStart: View {
    // Sends key events to the transport (e.g., Multipeer) using a "<KEY>_(DOWN|UP)" convention.
    var onPress: (String) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 20) {
            CapsuleGlassButton(
                title: "Select",
                onPress: { onPress("A_DOWN") },
                onRelease: { onPress("A_UP") }
            )
            
            CapsuleGlassButton(
                title: "Start",
                onPress: { onPress("S_DOWN") },
                onRelease: { onPress("S_UP") }
            )
        }
    }
}

// MARK: - CapsuleGlassButton
@available(iOS 26.0, *)
struct CapsuleGlassButton: View {
    let title: String
    let onPress: () -> Void     // Key down
    let onRelease: () -> Void   // Key up

    // Small, horizontal capsule dimensions
    private let width: CGFloat = 80
    private let height: CGFloat = 28
    private let cornerRadius: CGFloat = 16

    @State private var isPressed = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Button(action: {}) {
            ZStack {
                shape
                    .fill(Color.clear)
                    .frame(width: width, height: height)
                    // contentShape ensures taps/gestures use the rounded rect hit area
                    .contentShape(shape)
                    // Visual style (glass-like); assumes iOS 16+ Glass effect API
                    .glassEffect(.clear, in: shape)

                Text(title)
                    .foregroundStyle(.white.opacity(0.9))
                    .font(.system(size: 12, weight: .regular))
            }
        }
        // Custom style provides press scaling/opacity feedback separate from key events
        .buttonStyle(LiquidCapsuleButtonStyle())
        .accessibilityLabel(Text(title))
        // Use a zero-distance DragGesture to capture both press and release moments.
        // We guard with isPressed to avoid repeated onChanged callbacks while finger is held.
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        onPress()   // Key down
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    onRelease()  // Key up
                }
        )
    }
}

// MARK: - CapsuleGlassThemeButton
@available(iOS 26.0, *)
struct CapsuleGlassThemeButton: View {
    let title: String
    let onPress: () -> Void     // Key down
    let onRelease: () -> Void   // Key up

    // Small, square capsule dimensions
    private let width: CGFloat = 28
    private let height: CGFloat = 28
    private let cornerRadius: CGFloat = 10

    @State private var isPressed = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Button(action: {}) {
            ZStack {
                shape
                    .fill(Color.clear)
                    .frame(width: width, height: height)
                    .contentShape(shape)
                    .glassEffect(.clear, in: shape)

                Text(title)
                    .foregroundStyle(.white.opacity(0.9))
                    .font(.system(size: 12, weight: .regular))
            }
        }
        .buttonStyle(LiquidCapsuleButtonStyle())
        .accessibilityLabel(Text(title))
        // Same gesture approach to produce discrete DOWN/UP events.
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        onPress()   // Key down
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    onRelease()  // Key up
                }
        )
    }
}

#Preview {
    SelectStart()
}
