//
//  RecipesScreen.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import SwiftUI
import SwiftData

struct RecipesScreen: View {

	// MARK: - properties

	@Environment(RecipeCatalog.self) private var recipeCatalog

	@Query(
		sort: \FavoriteRecipe.createdAt,
		order: .reverse
	)
	private var favoriteRecipes: [FavoriteRecipe]

	@State private var searchText = ""


	// MARK: - body

	var body: some View {
		List {
			if
				normalizedSearchText.isEmpty,
				!favoriteRecipeItems.isEmpty
			{
				Section {
					ForEach(favoriteRecipeItems) { recipe in
						recipeRow(recipe)
					}
				} header: {
					Label(
						"Favorites",
						systemImage: "heart.fill"
					)
				}
			}

			ForEach(filteredCategories) { category in
				let recipes = filteredRecipes(
					for: category
				)

				if !recipes.isEmpty {
					Section {
						ForEach(recipes) { recipe in
							recipeRow(recipe)
						}
					} header: {
						Label(
							category.name,
							systemImage: category.systemImage
						)
					}
				}
			}
		}
		.navigationTitle("Recipes")
		.toolbarTitleDisplayMode(.inlineLarge)
		.scrollDismissesKeyboard(.interactively)
		.searchable(
			text: $searchText,
			placement: .navigationBarDrawer(
				displayMode: .automatic
			),
			prompt: "Search recipes"
		)
		.overlay {
			if
				!normalizedSearchText.isEmpty,
				filteredCategories.isEmpty
			{
				ContentUnavailableView.search(
					text: normalizedSearchText
				)
			}
		}
	}
}


// MARK: - views
private extension RecipesScreen {

	@ViewBuilder
	func recipeRow(
		_ recipe: Recipe
	) -> some View {
		NavigationLink {
			RecipesDetailView(
				recipe: recipe
			)
		} label: {
			VStack(alignment: .leading) {
				HStack(
					alignment: .center,
					spacing: 10
				) {
					Image(systemName: recipe.systemImage)
						.foregroundStyle(.tint)

					Text(recipe.title)
						.fontWeight(.medium)
				}

				Text(recipe.subtitle)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}
}


// MARK: - favorites
private extension RecipesScreen {

	var favoriteRecipeIDs: Set<String> {
		Set(
			favoriteRecipes.map(\.recipeID)
		)
	}

	var favoriteRecipeItems: [Recipe] {
		favoriteRecipes.compactMap { favorite in
			recipeCatalog.recipe(
				for: favorite.recipeID
			)
		}
	}
}


// MARK: - search
private extension RecipesScreen {

	var normalizedSearchText: String {
		searchText
			.trimmingCharacters(
				in: .whitespacesAndNewlines
			)
	}

	var filteredCategories: [RecipeCategory] {
		guard !normalizedSearchText.isEmpty else {
			return recipeCatalog.categories
		}

		return recipeCatalog.categories.filter { category in
			!filteredRecipes(
				for: category
			)
			.isEmpty
		}
	}

	func filteredRecipes(
		for category: RecipeCategory
	) -> [Recipe] {
		let recipes = recipeCatalog.recipes(
			for: category
		)

		guard !normalizedSearchText.isEmpty else {
			return recipes
		}

		return recipes.filter { recipe in
			recipeMatchesSearch(
				recipe,
				category: category
			)
		}
	}

	func recipeMatchesSearch(
		_ recipe: Recipe,
		category: RecipeCategory
	) -> Bool {
		let query = normalizedSearchText

		return recipe.title.localizedCaseInsensitiveContains(query) ||
			recipe.subtitle.localizedCaseInsensitiveContains(query) ||
			recipe.summary.localizedCaseInsensitiveContains(query) ||
			category.name.localizedCaseInsensitiveContains(query) ||
			recipe.settings.contains {
				$0.label.localizedCaseInsensitiveContains(query) ||
					$0.value.localizedCaseInsensitiveContains(query)
			} ||
			recipe.requirements.contains {
				$0.title.localizedCaseInsensitiveContains(query) ||
					(
						$0.detail?
							.localizedCaseInsensitiveContains(query)
						?? false
					)
			} ||
			recipe.tips.contains {
				(
					$0.title?
						.localizedCaseInsensitiveContains(query)
					?? false
				) ||
					$0.text.localizedCaseInsensitiveContains(query)
			}
	}
}


#Preview {
	NavigationStack {
		RecipesScreen()
	}
	.modelContainer(
		for: FavoriteRecipe.self,
		inMemory: true
	)
	.environment(RecipeCatalog())
}
