//
//  Dpad.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI

@available(iOS 26.0, *)
struct DPad: View {
    @Binding var directionPressed: String
    let mapping: KeyMapping
    var onPress: (String) -> Void = { _ in } // Sends key down/up events

    var body: some View {
        ZStack {
            // Vertical buttons: Up & Down
            VStack(spacing: 60) {
                CapsuleButton(
                    label: "Up",
                    width: 65,
                    height: 110,
                    arrow: "line.3.horizontal.decrease",
                    arrowRotation: .degrees(0),
                    arrowScale: CGSize(width: 0.09, height: 0.35),
                    onPress: {
                        directionPressed = "Up"
                        onPress("\(mapping.up)_DOWN")
                    },
                    onRelease: {
                        directionPressed = ""
                        onPress("\(mapping.up)_UP")
                    }
                )

                CapsuleButton(
                    label: "Down",
                    width: 65,
                    height: 110,
                    arrow: "line.3.horizontal.decrease",
                    arrowRotation: .degrees(180),
                    arrowScale: CGSize(width: 0.09, height: 0.35),
                    onPress: {
                        directionPressed = "Down"
                        onPress("\(mapping.down)_DOWN")
                    },
                    onRelease: {
                        directionPressed = ""
                        onPress("\(mapping.down)_UP")
                    }
                )
            }
            
            // Horizontal buttons: Left & Right
            HStack(spacing: 60) {
                CapsuleButton(
                    label: "Left",
                    width: 110,
                    height: 65,
                    arrow: "line.3.horizontal.decrease",
                    arrowRotation: .degrees(-90),
                    arrowScale: CGSize(width: 0.17, height: 0.6),
                    onPress: {
                        directionPressed = "Left"
                        onPress("\(mapping.left)_DOWN")
                    },
                    onRelease: {
                        directionPressed = ""
                        onPress("\(mapping.left)_UP")
                    }
                )

                CapsuleButton(
                    label: "Right",
                    width: 110,
                    height: 65,
                    arrow: "line.3.horizontal.decrease",
                    arrowRotation: .degrees(90),
                    arrowScale: CGSize(width: 0.17, height: 0.6),
                    onPress: {
                        directionPressed = "Right"
                        onPress("\(mapping.right)_DOWN")
                    },
                    onRelease: {
                        directionPressed = ""
                        onPress("\(mapping.right)_UP")
                    }
                )
            }
        }
        .frame(width: 220, height: 220)
    }
}

@available(iOS 26.0, *)
private struct CapsuleButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    let arrow: String
    let arrowRotation: Angle
    let arrowScale: CGSize
    let onPress: () -> Void       // Key down
    let onRelease: () -> Void     // Key up
    
    private let cornerRadius: CGFloat = 28
    @State private var isPressed = false

    init(label: String,
         width: CGFloat,
         height: CGFloat,
         arrow: String,
         arrowRotation: Angle = .degrees(0),
         arrowScale: CGSize = CGSize(width: 1, height: 1),
         onPress: @escaping () -> Void,
         onRelease: @escaping () -> Void) {
        self.label = label
        self.width = width
        self.height = height
        self.arrow = arrow
        self.arrowRotation = arrowRotation
        self.arrowScale = arrowScale
        self.onPress = onPress
        self.onRelease = onRelease
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        
        Button(action: {}) {
            ZStack {
                shape
                    .fill(Color.clear)
                    .frame(width: width, height: height)
                    .contentShape(shape)
                    .glassEffect(.clear, in: shape)

                Image(systemName: arrow)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(x: arrowScale.width, y: arrowScale.height)
                    .foregroundColor(.white)
                    .rotationEffect(arrowRotation)
                    .opacity(0.85)
                    .fontWeight(.thin)
            }
        }
        .buttonStyle(LiquidCapsuleButtonStyle())
        .accessibilityLabel(Text(label))
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
                    onRelease()   // Key up
                }
        )
    }
}
