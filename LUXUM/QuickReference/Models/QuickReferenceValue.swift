//
//  QuickReferenceValue.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct QuickReferenceValue: Codable, Identifiable, Hashable {
	
	let id: String
	let value: String
	let description: String
}
