//
//  Shapes.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI

@available(iOS 26.0, *)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

@available(iOS 26.0, *)
struct Polygon: Shape {
    var sides: Int
    func path(in rect: CGRect) -> Path {
        guard sides > 2 else { return Path() }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angle = 2 * .pi / CGFloat(sides)
        var path = Path()
        for i in 0..<sides {
            let x = center.x + radius * cos(CGFloat(i) * angle - .pi/2)
            let y = center.y + radius * sin(CGFloat(i) * angle - .pi/2)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

