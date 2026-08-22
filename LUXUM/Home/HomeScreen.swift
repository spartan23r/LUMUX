//
//  HomeScreen.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import SwiftUI
import SwiftData

struct HomeScreen: View {
	
	// MARK: - properties
	
	@Query private var ownedGear: [OwnedGearItem]
	@Query private var ownedFilters: [OwnedFilter]
	@Query private var ownedAccessories: [OwnedAccessory]
	@Query(
		sort: \FavoriteRecipe.createdAt,
		order: .reverse
	)
	private var favoriteRecipes: [FavoriteRecipe]
	
	@Environment(QuickReferenceCatalog.self)
	private var quickReferenceCatalog
	
	@Environment(RecipeCatalog.self)
	private var recipeCatalog
	
	@Environment(GearCatalog.self)
	private var gearCatalog
	
	@State private var learningTopics: [QuickReferenceTopic] = []
	@State private var suggestedRecipes: [Recipe] = []
	
	private let gearMatcher = RecipeGearMatcher()
	
	
	// MARK: - computed properties
	
	private var cameraCount: Int {
		ownedGear.filter {
			$0.kind == .camera
		}.count
	}
	
	private var lensCount: Int {
		ownedGear.filter {
			$0.kind == .lens
		}.count
	}
	
	private var filterCount: Int {
		ownedFilters.count
	}
	
	private var accessoryCount: Int {
		ownedAccessories.count
	}
	
	private var hasGear: Bool {
		cameraCount > 0 ||
		lensCount > 0 ||
		filterCount > 0 ||
		accessoryCount > 0
	}

	private var favoriteRecipeItems: [Recipe] {
		Array(
			favoriteRecipes
				.compactMap { favorite in
					recipeCatalog.recipe(
						for: favorite.recipeID
					)
				}
				.prefix(2)
		)
	}
	
	
	// MARK: - body
	
	var body: some View {
		List {
			
			// MARK: Your Gear
			
			Section {
				if hasGear {
					gearOverview
				} else {
					emptyGearView
				}
			}
			
			
			// MARK: Learn Today
			
			Section {
				ForEach(learningTopics) { topic in
					NavigationLink {
						QuickReferenceDetailView(
							topic: topic
						)
					} label: {
						learningTopicRow(
							topic
						)
					}
				}
			} header: {
				Label(
					"Learn Today",
					systemImage: "graduationcap"
				)
			}
			
			
			// MARK: Try a Recipe
			
			if !suggestedRecipes.isEmpty {
				Section {
					ForEach(suggestedRecipes) { recipe in
						NavigationLink {
							RecipesDetailView(
								recipe: recipe
							)
						} label: {
							recipeRow(
								recipe
							)
						}
					}
				} header: {
					Label(
						"Try a Recipe",
						systemImage: "camera.aperture"
					)
				}
			}



			// MARK: Favorite Recipes

			if !favoriteRecipeItems.isEmpty {
				Section {
					ForEach(favoriteRecipeItems) { recipe in
						NavigationLink {
							RecipesDetailView(
								recipe: recipe
							)
						} label: {
							favoriteRecipeRow(
								recipe
							)
						}
					}
				} header: {
					Label(
						"Recent Favorite Recipes",
						systemImage: "heart.fill"
					)
				}
			}
			
		}
		.navigationTitle("Home")
		.toolbarTitleDisplayMode(.inlineLarge)
		.onAppear {
			loadHomeContent()
		}
	}
}


// MARK: - utilities

private extension HomeScreen {
	
	func loadHomeContent() {
		loadLearningTopics()
		loadSuggestedRecipe()
	}
	
	func loadLearningTopics() {
		guard learningTopics.isEmpty else {
			return
		}
		
		learningTopics = Array(
			quickReferenceCatalog.topics
				.shuffled()
				.prefix(2)
		)
	}
	
	func loadSuggestedRecipe() {
		guard suggestedRecipes.isEmpty else {
			return
		}

		let favoriteIDs = Set(
			favoriteRecipes.map(\.recipeID)
		)

		let availableRecipes = recipeCatalog.recipes.filter {
			!favoriteIDs.contains($0.id)
		}

		guard hasGear else {
			suggestedRecipes = Array(
				availableRecipes
					.shuffled()
					.prefix(2)
			)

			return
		}

		let scoredRecipes = availableRecipes
			.map { recipe in
				(
					recipe: recipe,
					score: gearMatcher.gearMatchScore(
						for: recipe,
						ownedGear: ownedGear,
						ownedFilters: ownedFilters,
						ownedAccessories: ownedAccessories,
						gearCatalog: gearCatalog
					)
				)
			}
			.filter {
				$0.score > 0
			}
			.sorted {
				$0.score > $1.score
			}

		let bestMatches = Array(
			scoredRecipes.prefix(5)
		)

		let matchedRecipes = bestMatches
			.shuffled()
			.prefix(2)
			.map(\.recipe)

		if matchedRecipes.count == 2 {
			suggestedRecipes = Array(
				matchedRecipes
			)
		} else {
			let matchedIDs = Set(
				matchedRecipes.map(\.id)
			)

			let fallbackRecipes = availableRecipes
				.filter {
					!matchedIDs.contains($0.id)
				}
				.shuffled()

			suggestedRecipes = Array(
				(matchedRecipes + fallbackRecipes)
					.prefix(2)
			)
		}
	}


	func gearMatchScore(
		for recipe: Recipe
	) -> Double {
		gearMatcher.gearMatchScore(
			for: recipe,
			ownedGear: ownedGear,
			ownedFilters: ownedFilters,
			ownedAccessories: ownedAccessories,
			gearCatalog: gearCatalog
		)
	}
}


// MARK: - views

private extension HomeScreen {
	
	var gearOverview: some View {
		VStack(
			alignment: .leading,
			spacing: 16
		) {
			HStack(
				alignment: .center,
				spacing: 12
			) {
				Image(systemName: "backpack")
					.font(.title)
					.foregroundStyle(.tint)
				
				VStack(
					alignment: .leading,
					spacing: 2
				) {
					Text("My Gear")
						.font(.title3)
						.fontWeight(.semibold)
					
					Text("Your photography kit")
						.font(.subheadline)
						.foregroundStyle(.secondary)
				}
			}
			
			HStack(spacing: 0) {
				gearCount(
					value: cameraCount,
					title: cameraCount == 1
						? "Camera"
						: "Cameras"
				)
				
				Spacer()
				
				gearCount(
					value: lensCount,
					title: lensCount == 1
						? "Lens"
						: "Lenses"
				)
				
				Spacer()
				
				gearCount(
					value: filterCount,
					title: filterCount == 1
						? "Filter"
						: "Filters"
				)
				
				Spacer()
				
				gearCount(
					value: accessoryCount,
					title: accessoryCount == 1
						? "Accessory"
						: "Accessories"
				)
			}
		}
		.padding(.vertical, 8)
	}
	
	var emptyGearView: some View {
		HStack(
			alignment: .center,
			spacing: 12
		) {
			Image(systemName: "backpack")
				.font(.title2)
				.foregroundStyle(.tint.secondary)
			
			VStack(
				alignment: .leading,
				spacing: 2
			) {
				Text("No Gear Yet")
					.fontWeight(.medium)
				
				Text(
					"Add your gear to get personalized recommendations"
				)
				.font(.caption)
				.foregroundStyle(.secondary)
			}
		}
		.padding(.vertical, 4)
	}
	
	func gearCount(
		value: Int,
		title: String
	) -> some View {
		VStack(
			alignment: .leading,
			spacing: 2
		) {
			Text("\(value)")
				.font(.title2)
				.fontWeight(.semibold)
			
			Text(title)
				.font(.caption)
				.foregroundStyle(.secondary)
		}
	}
	
	func learningTopicRow(
		_ topic: QuickReferenceTopic
	) -> some View {
		VStack(
			alignment: .leading,
			spacing: 4
		) {
			HStack(
				alignment: .center,
				spacing: 10
			) {
				Image(systemName: topic.systemImage)
					.foregroundStyle(.tint)
				
				Text(topic.title)
					.fontWeight(.medium)
			}
			
			Text(topic.subtitle)
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.padding(.vertical, 2)
	}
	
	func favoriteRecipeRow(
		_ recipe: Recipe
	) -> some View {
		VStack(
			alignment: .leading,
			spacing: 4
		) {
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
		.padding(.vertical, 2)
	}


	func recipeRow(
		_ recipe: Recipe
	) -> some View {
		VStack(
			alignment: .leading,
			spacing: 6
		) {
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
			
			if gearMatchScore(for: recipe) > 0 {
				Text("Matches your gear")
					.font(.caption)
					.foregroundStyle(.tint)
			}
		}
		.padding(.vertical, 2)
	}
}


// MARK: - preview

#Preview {
	NavigationStack {
		HomeScreen()
	}
	.environment(
		QuickReferenceCatalog()
	)
	.environment(
		RecipeCatalog()
	)
	.environment(
		GearCatalog()
	)
	.modelContainer(
		for: [
			OwnedGearItem.self,
			OwnedFilter.self,
			OwnedAccessory.self,
			FavoriteRecipe.self
		],
		inMemory: true
	)
}
