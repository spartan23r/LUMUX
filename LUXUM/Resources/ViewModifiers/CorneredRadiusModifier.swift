//
//  CorneredRadiusModifier.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import SwiftUI

private protocol CorneredRadius {
	
	var radius: CGFloat { get }
}

private struct CorneredRadiusModifier: ViewModifier, CorneredRadius {
	
	var radius: CGFloat = 24
	
	func body(content: Content) -> some View {
		content
			.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
	}
}

extension View {
	
	/// Sets a rounded rectangle as a clipping shape for this view
	func corneredRadius(radius: CGFloat = 24) -> some View {
		return modifier(CorneredRadiusModifier(radius: radius))
	}
}
