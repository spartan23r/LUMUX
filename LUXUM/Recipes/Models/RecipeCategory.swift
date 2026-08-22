//
//  RecipeCategory.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct RecipeCategory: Codable, Identifiable, Hashable {
	
	let id: String
	let name: String
	let systemImage: String
	let recipeIDs: [String]
}
