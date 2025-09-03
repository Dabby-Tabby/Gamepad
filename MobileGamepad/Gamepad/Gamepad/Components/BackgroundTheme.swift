//
//  BackgroundTheme.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI

@available(iOS 26.0, *)
enum BackgroundTheme: String, CaseIterable {
    case forest
    case ocean
    case desert
    case galaxy

    var colors: [Color] {
        switch self {
        case .forest:
            return [
                Color(hex: "#0B3D2E"),
                Color(hex: "#3C6E47"),
                Color(hex: "#0B3D2E"),
                Color(hex: "#0B3D2E"),
                Color(hex: "#0D261C")
            ]
        case .ocean:
            return [
                Color(hex: "#0A3D62"),
                Color(hex: "#0B556D"),
                Color(hex: "#107896"),
                Color(hex: "#1B4965"),
                Color(hex: "#1C2833")
            ]
        case .desert:
            return [
                Color(hex: "#8B5E3C"),
                Color(hex: "#A0522D"),
                Color(hex: "#C1440E"),
                Color(hex: "#704214"),
                Color(hex: "#5C4033")
            ]
        case .galaxy:
            return [
                Color(hex: "#0D0D2B"),
                Color(hex: "#2C096F"),
                Color(hex: "#5A189A"),
                Color(hex: "#9D4EDD"),
                Color(hex: "#9D4EDD"),
                Color(hex: "#3A0CA3")
            ]
        }
    }

    // Declarative description of a blurred shape to render.
    var shapeDescriptors: [ShapeDescriptor] {
        switch self {
        case .forest:
            return [
                .circle(fill: Color.green.opacity(0.35), size: CGSize(width: 250, height: 250), blur: 80, rotation: .degrees(0), offset: CGSize(width: -120, height: -200)),
                .capsule(fill: Color.teal.opacity(0.25), size: CGSize(width: 200, height: 80), blur: 60, rotation: .degrees(-45), offset: CGSize(width: 150, height: -100)),
                .ellipse(fill: Color.mint.opacity(0.25), size: CGSize(width: 300, height: 180), blur: 100, rotation: .degrees(15), offset: CGSize(width: 80, height: 250)),
                .rectangle(fill: Color.green.opacity(0.2), size: CGSize(width: 180, height: 140), blur: 70, rotation: .degrees(30), offset: CGSize(width: -180, height: 180))
            ]
        case .ocean:
            return [
                .ellipse(fill: Color.blue.opacity(0.3), size: CGSize(width: 300, height: 180), blur: 80, rotation: .degrees(20), offset: CGSize(width: -120, height: -200)),
                .capsule(fill: Color.cyan.opacity(0.25), size: CGSize(width: 200, height: 90), blur: 80, rotation: .degrees(-30), offset: CGSize(width: 140, height: -150)),
                .circle(fill: Color.teal.opacity(0.25), size: CGSize(width: 250, height: 250), blur: 60, rotation: .degrees(0), offset: CGSize(width: 100, height: 250)),
                .triangle(fill: Color.blue.opacity(0.2), size: CGSize(width: 180, height: 180), blur: 70, rotation: .degrees(45), offset: CGSize(width: -180, height: 220))
            ]
        case .desert:
            return [
                .rectangle(fill: Color(hex: "#8B5E3C").opacity(0.3), size: CGSize(width: 280, height: 140), blur: 80, rotation: .degrees(15), offset: CGSize(width: -100, height: -150)),
                .circle(fill: Color(hex: "#C1440E").opacity(0.25), size: CGSize(width: 220, height: 220), blur: 70, rotation: .degrees(0), offset: CGSize(width: 120, height: -100)),
                .ellipse(fill: Color(hex: "#A0522D").opacity(0.25), size: CGSize(width: 300, height: 160), blur: 90, rotation: .degrees(-20), offset: CGSize(width: 80, height: 220)),
                .capsule(fill: Color(hex: "#704214").opacity(0.2), size: CGSize(width: 160, height: 80), blur: 60, rotation: .degrees(30), offset: CGSize(width: -150, height: 200))
            ]
        case .galaxy:
            return [
                .polygon(sides: 5, fill: Color(hex: "#5A189A").opacity(0.3), size: CGSize(width: 250, height: 250), blur: 100, rotation: .degrees(-30), offset: CGSize(width: -150, height: -200)),
                .circle(fill: Color(hex: "#3A0CA3").opacity(0.25), size: CGSize(width: 200, height: 200), blur: 80, rotation: .degrees(0), offset: CGSize(width: 160, height: -100)),
                .triangle(fill: Color(hex: "#2C096F").opacity(0.25), size: CGSize(width: 300, height: 300), blur: 120, rotation: .degrees(20), offset: CGSize(width: 100, height: 250)),
                .ellipse(fill: Color(hex: "#0D0D2B").opacity(0.2), size: CGSize(width: 180, height: 140), blur: 70, rotation: .degrees(-25), offset: CGSize(width: -180, height: 200))
            ]
        }
    }
}

// Strongly typed, renderable shape configuration (avoids AnyView).
@available(iOS 26.0, *)
enum ShapeDescriptor: Identifiable {
    case circle(fill: Color, size: CGSize, blur: CGFloat, rotation: Angle, offset: CGSize)
    case ellipse(fill: Color, size: CGSize, blur: CGFloat, rotation: Angle, offset: CGSize)
    case rectangle(fill: Color, size: CGSize, blur: CGFloat, rotation: Angle, offset: CGSize)
    case capsule(fill: Color, size: CGSize, blur: CGFloat, rotation: Angle, offset: CGSize)
    case triangle(fill: Color, size: CGSize, blur: CGFloat, rotation: Angle, offset: CGSize)
    case polygon(sides: Int, fill: Color, size: CGSize, blur: CGFloat, rotation: Angle, offset: CGSize)

    var id: UUID { UUID() }

    @ViewBuilder
    func view() -> some View {
        switch self {
        case let .circle(fill, size, blur, rotation, offset):
            Circle()
                .fill(fill)
                .frame(width: size.width, height: size.height)
                .blur(radius: blur)
                .rotationEffect(rotation)
                .offset(offset)
        case let .ellipse(fill, size, blur, rotation, offset):
            Ellipse()
                .fill(fill)
                .frame(width: size.width, height: size.height)
                .blur(radius: blur)
                .rotationEffect(rotation)
                .offset(offset)
        case let .rectangle(fill, size, blur, rotation, offset):
            Rectangle()
                .fill(fill)
                .frame(width: size.width, height: size.height)
                .blur(radius: blur)
                .rotationEffect(rotation)
                .offset(offset)
        case let .capsule(fill, size, blur, rotation, offset):
            Capsule()
                .fill(fill)
                .frame(width: size.width, height: size.height)
                .blur(radius: blur)
                .rotationEffect(rotation)
                .offset(offset)
        case let .triangle(fill, size, blur, rotation, offset):
            Triangle()
                .fill(fill)
                .frame(width: size.width, height: size.height)
                .blur(radius: blur)
                .rotationEffect(rotation)
                .offset(offset)
        case let .polygon(sides, fill, size, blur, rotation, offset):
            Polygon(sides: sides)
                .fill(fill)
                .frame(width: size.width, height: size.height)
                .blur(radius: blur)
                .rotationEffect(rotation)
                .offset(offset)
        }
    }
}

