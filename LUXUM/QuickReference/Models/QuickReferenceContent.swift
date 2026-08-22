//
//  QuickReferenceContent.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct QuickReferenceContent: Codable, Identifiable, Hashable {
	
	let id: String
	let type: QuickReferenceContentType
	
	let text: String?
	let values: [QuickReferenceValue]?
}

enum QuickReferenceContentType: String, Codable {
	case text
	case values
	case tip
	case warning
}
