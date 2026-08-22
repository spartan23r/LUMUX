//
//  RecipeTip.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct RecipeTip: Codable, Identifiable, Hashable {
	
	let id: String
	let title: String?
	let text: String
}
