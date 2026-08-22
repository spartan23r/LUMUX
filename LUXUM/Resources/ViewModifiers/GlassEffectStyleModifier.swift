//
//  GlassEffectStyleModifier.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import SwiftUI

private struct GlassEffectStyleModifier: ViewModifier {
	
	var color: Color? = nil
	var interactive: Bool? = nil
	var cornerRadius: CGFloat = 24
	
	func body(content: Content) -> some View {
		if let color = color {
			if let interactive = interactive {
				content
					.glassEffect(.regular.tint(color).interactive(interactive), in: .rect(cornerRadius: cornerRadius))
			} else {
				content
					.glassEffect(.regular.tint(color), in: .rect(cornerRadius: cornerRadius))
			}
		} else {
			if let interactive = interactive {
				content
					.glassEffect(.regular.interactive(interactive), in: .rect(cornerRadius: cornerRadius))
			} else {
				content
					.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
			}
		}
	}
}

extension View {
	
	func glassEffectStyle(color: Color? = nil, interactive: Bool? = nil, cornerRadius: CGFloat = 24) -> some View {
		return modifier(GlassEffectStyleModifier(color: color, interactive: interactive, cornerRadius: cornerRadius))
	}
}
