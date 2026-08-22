//
//  RecipeSetting.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct RecipeSetting: Codable, Identifiable, Hashable {
	
	let id: String
	let label: String
	let value: String
	let note: String?
}
