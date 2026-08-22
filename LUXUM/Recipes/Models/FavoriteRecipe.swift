//
//  FavoriteRecipe.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteRecipe {
	var recipeID: String
	var createdAt: Date

	init(
		recipeID: String,
		createdAt: Date = .now
	) {
		self.recipeID = recipeID
		self.createdAt = createdAt
	}
}
