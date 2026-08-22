//
//  QuickReferenceCategory.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct QuickReferenceCategory: Codable, Identifiable, Hashable {
	
	let id: String
	let name: String
	let systemImage: String
	let topicIDs: [String]
}
