//
//  RecipeCatalog.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation
import Observation

@Observable
final class RecipeCatalog {
	
	private(set) var categories: [RecipeCategory] = []
	private(set) var recipes: [Recipe] = []
	
	init() {
		categories = Self.load("recipe-categories", as: RecipeCategoryCatalog.self).categories
		recipes = Self.load("recipes", as: RecipeCollection.self).recipes
	}
	
	private static func load<T: Decodable>(_ filename: String, as type: T.Type) -> T {
		guard let url = Bundle.main.url(
			forResource: filename,
			withExtension: "json"
		) else {
			fatalError("Could not find \(filename).json")
		}
		
		do {
			let data = try Data(contentsOf: url)
			
			return try JSONDecoder().decode(
				T.self,
				from: data
			)
		} catch {
			fatalError(
				"Could not decode \(filename).json: \(error)"
			)
		}
	}
}

extension RecipeCatalog {
	
	func recipe(for id: String) -> Recipe? {
		recipes.first { $0.id == id }
	}
	
	func recipes(
		for category: RecipeCategory
	) -> [Recipe] {
		category.recipeIDs.compactMap { id in
			recipe(for: id)
		}
	}
}

struct RecipeCategoryCatalog: Codable {
	let categories: [RecipeCategory]
}

struct RecipeCollection: Codable {
	let recipes: [Recipe]
}
