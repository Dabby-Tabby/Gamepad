//
//  ContentView.swift
//  GamepadReceiver
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI
import Cocoa

// MARK: - Keyboard Manager
// Translates simple letter/number labels into US virtual key codes and posts HID events.
// Note: This uses CGEvent to synthesize key presses on macOS; ensure the app has accessibility permissions.
// Security: macOS will require "Accessibility" permissions in Privacy settings for event posting to work.
class KeyboardManager {
    static let shared = KeyboardManager()
    
    // US Keyboard virtual keycodes
    private let keyMap: [String: CGKeyCode] = [
        "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5,
        "Z": 6, "X": 7, "C": 8, "V": 9, "B": 11,
        "Q": 12, "W": 13, "E": 14, "R": 15, "Y": 16, "T": 17,
        "1": 18, "2": 19, "3": 20, "4": 21, "6": 22, "5": 23,
        "7": 26, "8": 28, "9": 25, "0": 29,
        "I": 34, "O": 31, "P": 35, "U": 32,
        "J": 38, "K": 40, "L": 37,
        "N": 45, "M": 46, ",": 43, ".": 47
    ]
    
    // MARK: Event Synthesis
    // Converts a gamepad label into a CGEvent key press/release.
    // Threading: CGEvent posting should occur on a thread that can interact with the HID event tap; this is fine on main.
    func sendKey(label: String, down: Bool) {
        guard let code = keyMap[label.uppercased()] else { return }
        let event = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: down)
        event?.post(tap: .cghidEventTap)
    }
}

// MARK: - Content View
// Listens for "<KEY>_(DOWN|UP)" messages via Multipeer and mirrors them to the local keyboard.
// Displays a simple grid to visualize currently held keys.
struct ContentView: View {
    @StateObject private var multipeerManager = MultipeerManager()
    @State private var heldKeys: Set<String> = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Gamepad Receiver")
                .font(.largeTitle)
                .padding()
            
            // Visual key grid (grouped by theme columns)
            HStack(spacing: 20) {
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        KeyView(label: "1", isActive: heldKeys.contains("1"))
                        KeyView(label: "2", isActive: heldKeys.contains("2"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "Q", isActive: heldKeys.contains("Q"))
                        KeyView(label: "W", isActive: heldKeys.contains("W"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "A", isActive: heldKeys.contains("A"))
                        KeyView(label: "S", isActive: heldKeys.contains("S"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "Z", isActive: heldKeys.contains("Z"))
                        KeyView(label: "X", isActive: heldKeys.contains("X"))
                    }
                }
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        KeyView(label: "3", isActive: heldKeys.contains("3"))
                        KeyView(label: "4", isActive: heldKeys.contains("4"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "E", isActive: heldKeys.contains("E"))
                        KeyView(label: "R", isActive: heldKeys.contains("R"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "D", isActive: heldKeys.contains("D"))
                        KeyView(label: "F", isActive: heldKeys.contains("F"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "C", isActive: heldKeys.contains("C"))
                        KeyView(label: "V", isActive: heldKeys.contains("V"))
                    }
                }
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        KeyView(label: "5", isActive: heldKeys.contains("5"))
                        KeyView(label: "6", isActive: heldKeys.contains("6"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "T", isActive: heldKeys.contains("T"))
                        KeyView(label: "Y", isActive: heldKeys.contains("Y"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "G", isActive: heldKeys.contains("G"))
                        KeyView(label: "H", isActive: heldKeys.contains("H"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "B", isActive: heldKeys.contains("B"))
                        KeyView(label: "N", isActive: heldKeys.contains("N"))
                    }
                }
                VStack(spacing: 10) {
                    HStack(spacing: 5) {
                        KeyView(label: "7", isActive: heldKeys.contains("7"))
                        KeyView(label: "8", isActive: heldKeys.contains("8"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "U", isActive: heldKeys.contains("U"))
                        KeyView(label: "I", isActive: heldKeys.contains("I"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "J", isActive: heldKeys.contains("J"))
                        KeyView(label: "K", isActive: heldKeys.contains("K"))
                    }
                    HStack(spacing: 5) {
                        KeyView(label: "M", isActive: heldKeys.contains("M"))
                        KeyView(label: ",", isActive: heldKeys.contains(","))
                    }
                }
            }
            Spacer()
        }
        .frame(width: 400, height: 300)
        // MARK: Message Handling
        // Converts "<KEY>_(DOWN|UP)" into local key state and synthesizes macOS key events.
        // Contract: Messages are trusted to be single ASCII labels mapped in KeyboardManager.
        .onReceive(multipeerManager.$lastKeyPressed) { key in
            guard let key = key else { return }
            if key.hasSuffix("_DOWN") {
                let k = key.replacingOccurrences(of: "_DOWN", with: "")
                heldKeys.insert(k)
                KeyboardManager.shared.sendKey(label: k, down: true)
            } else if key.hasSuffix("_UP") {
                let k = key.replacingOccurrences(of: "_UP", with: "")
                heldKeys.remove(k)
                KeyboardManager.shared.sendKey(label: k, down: false)
            }
        }
    }
}

// MARK: - Key View
// Simple visual representation of a key with active/inactive state.
struct KeyView: View {
    let label: String
    let isActive: Bool
    
    var body: some View {
        Text(label)
            .font(.title)
            .frame(width: 70, height: 70)
            .background(isActive ? Color.green : Color.gray.opacity(0.3))
            .cornerRadius(10)
            .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

