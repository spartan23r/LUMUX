//
//  QuickReferenceSection.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct QuickReferenceSection: Codable, Identifiable, Hashable {
	
	let id: String
	let title: String?
	let content: [QuickReferenceContent]
}
