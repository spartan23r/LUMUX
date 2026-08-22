//
//  XPasteboard.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

#if os(macOS)
import AppKit
typealias XPasteboard = NSPasteboard
#else
import UIKit
typealias XPasteboard = UIPasteboard
#endif

extension XPasteboard {
	func copyText(_ text: String) {
#if os(macOS)
		self.clearContents()
		self.setString(text, forType: .string)
#else
		self.string = text
#endif
	}
}
