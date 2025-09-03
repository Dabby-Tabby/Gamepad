//
//  BackgroundView.swift
//  Gamepad
//
//  Created by Nick Watts on 8/31/25.
//

import SwiftUI

// MARK: - Overview
// Renders a themed gradient background with decorative shapes supplied by BackgroundTheme.

@available(iOS 26.0, *)
struct BackgroundView: View {
    @Binding var theme: BackgroundTheme

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: theme.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Theme provides a collection of shape descriptors to overlay
                ForEach(theme.shapeDescriptors) { descriptor in
                    descriptor.view()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
}
