//
//  ListRoundedIconStyleModifier.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import SwiftUI

private protocol ListRoundedIconStyle {
	
	var bgc: Color { get }
	var filledIconStyle: Bool { get }
}

private struct ListRoundedIconStyleModifier: ViewModifier, ListRoundedIconStyle {
	
	var bgc: Color
	var filledIconStyle: Bool
	
	func body(content: Content) -> some View {
		content
			.foregroundStyle(.white)
			.symbolVariant(filledIconStyle ? .fill : .none)
			.frame(width: 34, height: 34)
			.glassEffectStyle(color: bgc, cornerRadius: 12)
	}
}

extension View {
	
	func listRoundedIconStyle(bgc: Color = .accentColor, filledIconStyle: Bool = false) -> some View {
		return modifier(ListRoundedIconStyleModifier(bgc: bgc, filledIconStyle: filledIconStyle))
	}
}
