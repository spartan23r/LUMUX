//
//  RecipeRequirement.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct RecipeRequirement: Codable, Identifiable, Hashable {
	
	let id: String
	let type: RecipeRequirementType
	let title: String
	let detail: String?
}

enum RecipeRequirementType: String, Codable {
	case focalLength
	case aperture
	case tripod
	case ndFilter
	case cplFilter
	case stabilization
	case flash
	case other
}
