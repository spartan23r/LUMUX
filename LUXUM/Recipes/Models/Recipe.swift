//
//  Recipe.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct Recipe: Codable, Identifiable, Hashable {
	
	let id: String
	let categoryID: String
	
	let title: String
	let subtitle: String
	let systemImage: String
	
	let summary: String
	
	let settings: [RecipeSetting]
	let requirements: [RecipeRequirement]
	let tips: [RecipeTip]
	
	let gearProfile: RecipeGearProfile?
	
	let relatedReferenceIDs: [String]
}
