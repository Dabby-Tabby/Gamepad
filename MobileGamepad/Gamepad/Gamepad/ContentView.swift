//
//  ContentView.swift
//  Gamepad
//
//  Created by Nick Watts on 8/28/25.
//

import SwiftUI

// MARK: - Key Mapping
// Encapsulates the letter/number mapping per theme for each gamepad control.
// Contract: These labels must match the macOS receiver's KeyboardManager key map.
struct KeyMapping {
    let up: String
    let down: String
    let left: String
    let right: String
    let a: String
    let b: String
    let select: String
    let start: String
}

extension KeyMapping {
    static let theme1 = KeyMapping(
        up: "1", down: "2", left: "Q", right: "W",
        a: "A", b: "S", select: "Z", start: "X"
    )
    static let theme2 = KeyMapping(
        up: "3", down: "4", left: "E", right: "R",
        a: "D", b: "F", select: "C", start: "V"
    )
    static let theme3 = KeyMapping(
        up: "5", down: "6", left: "T", right: "Y",
        a: "G", b: "H", select: "B", start: "N"
    )
    static let theme4 = KeyMapping(
        up: "7", down: "8", left: "U", right: "I",
        a: "J", b: "K", select: "M", start: ","
    )
}

// MARK: - Theme Routing
// Centralized helpers to translate a numeric theme index into a BackgroundTheme and KeyMapping.
// Keeps View logic simple and makes it easier to add new themes in one place.
// Note: BackgroundTheme and BackgroundView are assumed to be defined elsewhere in the Gamepad target.
@available(iOS 26.0, *)
private enum ThemeRouting {
    static func theme(for index: Int) -> BackgroundTheme {
        switch index {
        case 1: return .forest
        case 2: return .ocean
        case 3: return .desert
        case 4: return .galaxy
        default: return .forest
        }
    }
    
    static func mapping(for index: Int) -> KeyMapping {
        switch index {
        case 1: return .theme1
        case 2: return .theme2
        case 3: return .theme3
        case 4: return .theme4
        default: return .theme1
        }
    }
}

@available(iOS 26.0, *)
struct ContentView: View {
    // MARK: State
    @State private var directionPressed: String = ""
    @State private var actionPressed: String = ""
    @StateObject private var multipeerManager = MultipeerManager()
    @StateObject private var gyroManager = GyroManager()
    
    @State private var currentThemeIndex: Int = 1
    
    private var currentMapping: KeyMapping {
        ThemeRouting.mapping(for: currentThemeIndex)
    }
    
    private var currentTheme: BackgroundTheme {
        ThemeRouting.theme(for: currentThemeIndex)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // MARK: Background
                // Bound as a constant since we mutate via theme index, not by two-way binding.
                BackgroundView(theme: .constant(currentTheme))
                
                VStack {
                    // MARK: Top Controls (Select / Theme / Gyro / Recenter / Start)
                    HStack(spacing: 25) {
                        // Select (press/release mapped via Multipeer)
                        CapsuleGlassButton(
                            title: "Select",
                            onPress: { multipeerManager.send("\(currentMapping.select)_DOWN") },
                            onRelease: { multipeerManager.send("\(currentMapping.select)_UP") }
                        )
                        
                        // Theme switcher (press toggles theme immediately; no release action)
                        CapsuleGlassThemeButton(
                            title: "\(currentThemeIndex)",
                            onPress: {
                                // Cycles 1→4 repeatedly. Theme is purely local UI state.
                                currentThemeIndex = (currentThemeIndex % 4) + 1
                            },
                            onRelease: { }
                        )
                        
                        // Gyro toggle styled like glass capsule
                        CapsuleGlassSmallButton(
                            title: "Gyro",
                            activeTint: .blue.opacity(0.25),
                            isActive: gyroManager.isActive,
                            onPress: {
                                // Toggle begins on press to feel responsive like other buttons.
                                // Side effects: start/stop motion updates and forward generated keys via Multipeer.
                                if gyroManager.isActive {
                                    gyroManager.stopGyroUpdates(mapping: currentMapping) { key in
                                        multipeerManager.send(key)
                                    }
                                } else {
                                    gyroManager.startGyroUpdates(mapping: currentMapping) { key in
                                        multipeerManager.send(key)
                                    }
                                }
                            },
                            onRelease: { }
                        )
                        
                        // Recenter button appears in gyro mode, styled to match.
                        // Uses transition to animate appearance/disappearance.
                        if gyroManager.isActive {
                            CapsuleGlassSmallButton(
                                title: "Recenter",
                                activeTint: .green.opacity(0.25),
                                isActive: true,
                                onPress: {
                                    // Sets a new yaw baseline; see GyroManager.recenter.
                                    gyroManager.recenter()
                                },
                                onRelease: { }
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Start (press/release mapped via Multipeer)
                        CapsuleGlassButton(
                            title: "Start",
                            onPress: { multipeerManager.send("\(currentMapping.start)_DOWN") },
                            onRelease: { multipeerManager.send("\(currentMapping.start)_UP") }
                        )
                    }
                    .offset(y: 170)
                    .animation(.spring(), value: gyroManager.isActive)
                }
                
                // MARK: Main Controls (D-Pad and AB buttons)
                HStack(spacing: 150) {
                    DPad(directionPressed: $directionPressed,
                         mapping: currentMapping) { key in
                        // If gyro is active, DPad is disabled from sending keys to avoid conflicts.
                        if !gyroManager.isActive {
                            multipeerManager.send(key)
                        }
                    }
                         .frame(width: geo.size.width * 0.4, height: geo.size.height)
                    
                    HStack(spacing: 50) {
                        PressReleaseButton(
                            title: "A",
                            onPress: {
                                actionPressed = "A"
                                multipeerManager.send("\(currentMapping.a)_DOWN")
                            },
                            onRelease: {
                                actionPressed = ""
                                multipeerManager.send("\(currentMapping.a)_UP")
                            }
                        )
                        .offset(x: -20, y: -20)
                        
                        PressReleaseButton(
                            title: "B",
                            onPress: {
                                actionPressed = "B"
                                multipeerManager.send("\(currentMapping.b)_DOWN")
                            },
                            onRelease: {
                                actionPressed = ""
                                multipeerManager.send("\(currentMapping.b)_UP")
                            }
                        )
                        .offset(x: -20, y: 20)
                    }
                    .frame(width: geo.size.width * 0.4, height: geo.size.height)
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - PressReleaseButton
// A compact button that emits explicit onPress/onRelease events using a DragGesture.
// We avoid Button's default action to retain DOWN/UP semantics and continuous press handling.
@available(iOS 26.0, *)
private struct PressReleaseButton: View {
    let title: String
    let onPress: () -> Void
    let onRelease: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {}) {
            Text(title)
                .fontWeight(.regular)
        }
        .buttonStyle(LiquidGlassButtonStyle())
        // Gesture emits DOWN on first movement and UP on end; `isPressed` guards repeats.
        // Note: DragGesture(minimumDistance: 0) is used to capture both tap and press-and-hold.
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        onPress()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    onRelease()
                }
        )
    }
}

// MARK: - Small Capsule Glass Button (matches CapsuleGlassButton style)
// Sends onPress immediately and onRelease on gesture end. Highlights with activeTint when active.
@available(iOS 26.0, *)
private struct CapsuleGlassSmallButton: View {
    let title: String
    let activeTint: Color
    let isActive: Bool
    let onPress: () -> Void
    let onRelease: () -> Void
    
    private let width: CGFloat = 70
    private let height: CGFloat = 28
    private let cornerRadius: CGFloat = 16
    
    @State private var pressed = false
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        
        Button(action: {}) {
            ZStack {
                shape
                    .fill(Color.clear)
                    .frame(width: width, height: height)
                    .overlay(
                        shape.fill(isActive ? activeTint : Color.clear)
                    )
                    .contentShape(shape)
                    .glassEffect(.clear, in: shape)
                
                Text(title)
                    .foregroundStyle(.white.opacity(0.9))
                    .font(.system(size: 12, weight: .regular))
            }
        }
        .buttonStyle(LiquidCapsuleButtonStyle())
        // Gesture emits DOWN on first movement and UP on end; `pressed` guards repeats.
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !pressed {
                        pressed = true
                        onPress()
                    }
                }
                .onEnded { _ in
                    pressed = false
                    onRelease()
                }
        )
        .accessibilityLabel(Text(title))
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}

