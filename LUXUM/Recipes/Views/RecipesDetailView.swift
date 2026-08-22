//
//  RecipesDetailView.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import SwiftUI
import SwiftData

struct RecipesDetailView: View {

	// MARK: - properties

	let recipe: Recipe

	@Query private var ownedGear: [OwnedGearItem]
	@Query private var ownedFilters: [OwnedFilter]
	@Query private var ownedAccessories: [OwnedAccessory]
	@Query private var favoriteRecipes: [FavoriteRecipe]

	@Environment(GearCatalog.self) private var gearCatalog
	@Environment(QuickReferenceCatalog.self) private var quickReferenceCatalog
	@Environment(\.modelContext) private var modelContext

	private let gearMatcher = RecipeGearMatcher()


	// MARK: - body

	var body: some View {
		List {
			Section {
				headerView
			}

			if !recipe.settings.isEmpty {
				Section("Recommended Settings") {
					ForEach(recipe.settings) { setting in
						VStack(
							alignment: .leading,
							spacing: 4
						) {
							LabeledContent(
								setting.label,
								value: setting.value
							)

							if let note = setting.note {
								Text(note)
									.font(.caption)
									.foregroundStyle(.secondary)
							}
						}
					}
				}
			}

			if let bestLensMatch {
				Section("Gear Match") {
					matchingLensRow(
						for: bestLensMatch,
						label: "Best match",
						image: "star",
						showsReason: true
					)

					if !alternativeLensMatches.isEmpty {
						DisclosureGroup {
							ForEach(
								Array(alternativeLensMatches.enumerated()),
								id: \.offset
							) { _, match in
								matchingLensRow(
									for: match,
									label: match.quality.title
								)
							}
						} label: {
							VStack(
								alignment: .leading,
								spacing: 4
							) {
								Text("Other Matching Lenses")

								Text(
									"\(alternativeLensMatches.count) \(alternativeLensMatches.count == 1 ? "lens" : "lenses") in My Gear"
								)
								.font(.caption)
								.foregroundStyle(.secondary)
							}
						}
					}
				}
				.listSectionSpacing(
					hasRecommendedAccessories
						? .compact
						: .default
				)
			}

			if
				let profile = recipe.gearProfile,
				hasRecommendedAccessories
			{
				Section {
					if
						profile.recommendsNDFilter,
						let filter = ownedNDFilter
					{
						ownedFilterRow(
							filter,
							label: "Recommended filter"
						)
					}

					if
						profile.recommendsCPLFilter,
						let filter = ownedCPLFilter
					{
						ownedFilterRow(
							filter,
							label: "Recommended filter"
						)
					}

					if
						profile.requiresTripod,
						let accessory = ownedTripod
					{
						ownedAccessoryRow(
							accessory,
							label: "Required"
						)
					}

					if
						profile.recommendsFlash,
						let accessory = ownedFlash
					{
						ownedAccessoryRow(
							accessory,
							label: "Recommended"
						)
					}
				}
			}

			if !recipe.requirements.isEmpty {
				Section("Recommended Gear") {
					ForEach(recipe.requirements) { requirement in
						VStack(
							alignment: .leading,
							spacing: 4
						) {
							Text(requirement.title)
								.fontWeight(.medium)

							if let detail = requirement.detail {
								Text(detail)
									.font(.caption)
									.foregroundStyle(.secondary)
							}
						}
						.padding(.vertical, 2)
					}
				}
			}

			if !recipe.tips.isEmpty {
				Section("Tips") {
					ForEach(recipe.tips) { tip in
						VStack(
							alignment: .leading,
							spacing: 4
						) {
							if let title = tip.title {
								Text(title)
									.fontWeight(.medium)
							}

							Text(tip.text)
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						.padding(.vertical, 2)
					}
				}
			}


			if !relatedQuickReferences.isEmpty {
				Section {
					ForEach(relatedQuickReferences) { topic in
						NavigationLink {
							QuickReferenceDetailView(
								topic: topic
							)
						} label: {
							VStack(
								alignment: .leading,
								spacing: 4
							) {
								HStack(
									alignment: .center,
									spacing: 10
								) {
									Image(
										systemName: topic.systemImage
									)
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
					}
				} header: {
					Label(
						"Learn More",
						systemImage: "graduationcap"
					)
				}
			}
		}
		.navigationTitle("Recipe")
		.navigationSubtitle(recipe.title)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					toggleFavorite()
				} label: {
					Image(
						systemName: isFavorite
							? "heart.fill"
							: "heart"
					)
				}
				.tint(isFavorite ? .pink : .primary)
				.accessibilityLabel(
					isFavorite
						? "Remove from favorites"
						: "Add to favorites"
				)
			}
		}
	}
}


// MARK: - views
private extension RecipesDetailView {

	var headerView: some View {
		VStack(
			alignment: .leading,
			spacing: 12
		) {
			HStack(
				alignment: .center,
				spacing: 12
			) {
				Image(systemName: recipe.systemImage)
					.font(.title)
					.foregroundStyle(.tint)

				Text(recipe.title)
					.font(.title2)
					.fontWeight(.semibold)
			}

			Text(recipe.subtitle)
				.font(.title3)
				.foregroundStyle(.secondary)

			Text(recipe.summary)
		}
		.padding(.vertical, 8)
	}

	func matchingLensRow(
		for match: RecipeGearMatcher.LensMatch,
		label: String,
		image: String? = nil,
		showsReason: Bool = false
	) -> some View {
		VStack(
			alignment: .leading,
			spacing: 4
		) {
			HStack {
				Text(match.lens.name)
					.fontWeight(.medium)

				Spacer()

				if let image {
					Image(systemName: image)
						.symbolVariant(.circle.fill)
						.foregroundStyle(.white, .tint)
				}
			}
			.frame(
				maxWidth: .infinity,
				alignment: .leading
			)
			
			Grid {
				GridRow {
					
					if let brand = gearCatalog.brand(for: match.lens.brandID) {
						Text(brand.name)
					}
					
					Text("·")
					Text(focalLengthText(min: match.lens.focalLengthMin, max: match.lens.focalLengthMax))
					
					Text("·")
					Text(apertureText(wide: match.lens.maxApertureWide,tele: match.lens.maxApertureTele))
					
				}
			}
			.font(.caption)
			.foregroundStyle(.secondary)

			Text(label)
				.font(.caption)
				.foregroundStyle(.tint)

			if showsReason {
				Text(match.reason)
					.font(.caption)
					.foregroundStyle(.secondary)
					.padding(.top, 2)
			}
		}
		.padding(.vertical, 2)
	}

//	func lensMetadata(
//		for match: RecipeGearMatcher.LensMatch
//	) -> String {
//		var parts: [String] = []
//
//		if let brand = gearCatalog.brand(
//			for: match.lens.brandID
//		) {
//			parts.append(brand.name)
//		}
//
//		if let camera = match.camera {
//			parts.append(camera.name)
//		}
//
//		return parts.joined(
//			separator: " · "
//		)
//	}

	func ownedFilterRow(
		_ filter: OwnedFilter,
		label: String
	) -> some View {
		VStack(
			alignment: .leading,
			spacing: 4
		) {
			HStack {
				Text(filter.name)
					.fontWeight(.medium)

				Spacer()

				Image(systemName: "star")
					.symbolVariant(.circle.fill)
					.foregroundStyle(.white, .tint)
			}
			
			Grid {
				GridRow {
					
					if let brand = filter.brand {
						Text(brand)
					}
					
					if let diameter = filter.diameter {
						Text("·")
						Text("\(diameter)" + " mm")
					}
					
					if let strength = filter.strength {
						Text("·")
						Text(strength)
					} else {
						Text("·")
						Text(filter.kind.title)
					}
					
				}
			}
			.font(.caption)
			.foregroundStyle(.secondary)

			Text(label)
				.font(.caption)
				.foregroundStyle(.tint)
		}
		.padding(.vertical, 2)
	}

	func ownedAccessoryRow(
		_ accessory: OwnedAccessory,
		label: String
	) -> some View {
		VStack(
			alignment: .leading,
			spacing: 4
		) {
			HStack {
				Text(accessory.name)
					.fontWeight(.medium)

				Spacer()

				Image(systemName: "star")
					.symbolVariant(.circle.fill)
					.foregroundStyle(.white, .tint)
			}

			Grid {
				GridRow {
					
					if let brand = accessory.brand {
						Text(brand)
					}
					
					Text("·")
					Text(accessory.kind.title)
					
				}
			}
			.font(.caption)
			.foregroundStyle(.secondary)

			Text(label)
				.font(.caption)
				.foregroundStyle(.tint)
		}
		.padding(.vertical, 2)
	}
}


// MARK: - matching
private extension RecipesDetailView {

	var hasRecommendedAccessories: Bool {
		(
			recipe.gearProfile?.recommendsNDFilter == true &&
			ownedNDFilter != nil
		) ||
		(
			recipe.gearProfile?.recommendsCPLFilter == true &&
			ownedCPLFilter != nil
		) ||
		(
			recipe.gearProfile?.requiresTripod == true &&
			ownedTripod != nil
		) ||
		(
			recipe.gearProfile?.recommendsFlash == true &&
			ownedFlash != nil
		)
	}

	var lensMatches: [RecipeGearMatcher.LensMatch] {
		gearMatcher.lensMatches(
			for: recipe,
			ownedGear: ownedGear,
			gearCatalog: gearCatalog
		)
	}

	var bestLensMatch: RecipeGearMatcher.LensMatch? {
		lensMatches.first
	}

	var alternativeLensMatches: [RecipeGearMatcher.LensMatch] {
		Array(
			lensMatches.dropFirst()
		)
	}

	var ownedNDFilter: OwnedFilter? {
		gearMatcher.ownedNDFilter(
			in: ownedFilters
		)
	}

	var ownedCPLFilter: OwnedFilter? {
		gearMatcher.ownedCPLFilter(
			in: ownedFilters
		)
	}

	var ownedTripod: OwnedAccessory? {
		gearMatcher.ownedTripod(
			in: ownedAccessories
		)
	}

	var ownedFlash: OwnedAccessory? {
		gearMatcher.ownedFlash(
			in: ownedAccessories
		)
	}
}

// MARK: - quick reference
private extension RecipesDetailView {

	var relatedQuickReferences: [QuickReferenceTopic] {
		var seenIDs = Set<String>()

		return recipe.relatedReferenceIDs
			.compactMap { id in
				guard !seenIDs.contains(id) else {
					return nil
				}

				guard let topic = quickReferenceCatalog.topic(
					for: id
				) else {
					return nil
				}

				seenIDs.insert(id)
				return topic
			}
	}
}


// MARK: - favorites
private extension RecipesDetailView {

	var favoriteRecipe: FavoriteRecipe? {
		favoriteRecipes.first {
			$0.recipeID == recipe.id
		}
	}

	var isFavorite: Bool {
		favoriteRecipe != nil
	}

	func toggleFavorite() {
		if let favoriteRecipe {
			modelContext.delete(
				favoriteRecipe
			)
		} else {
			let favorite = FavoriteRecipe(
				recipeID: recipe.id
			)

			modelContext.insert(
				favorite
			)
		}

		do {
			try modelContext.save()
		} catch {
			assertionFailure(
				"Could not update favorite recipe: \(error)"
			)
		}
	}
}


// MARK: - formatters
extension RecipesDetailView {
	
	func focalLengthText(min: Double, max: Double) -> String {
		if min == max {
			return "\(formatted(min)) mm"
		}
		
		return "\(formatted(min))–\(formatted(max)) mm"
	}
	
	func apertureText(wide: Double, tele: Double) -> String {
		if wide == tele {
			return "F\(formatted(wide))"
		}
		
		return "F\(formatted(wide))–\(formatted(tele))"
	}
	
	func formatted(_ value: Double) -> String {
		value.formatted(
			.number
				.locale(Locale(identifier: "en_US"))
				.precision(.fractionLength(0...2))
		)
	}
}

// MARK: - preview
#Preview {
	NavigationStack {
		RecipesDetailView(
			recipe: Recipe(
				id: "waterfalls",
				categoryID: "landscape",
				title: "Waterfalls",
				subtitle: "Create smooth, flowing water",
				systemImage: "water.waves",
				summary: "Use a slow shutter speed to blur moving water while keeping the surrounding landscape sharp.",
				settings: [
					RecipeSetting(
						id: "waterfalls-mode",
						label: "Mode",
						value: "Manual",
						note: nil
					),
					RecipeSetting(
						id: "waterfalls-aperture",
						label: "Aperture",
						value: "F8–F11",
						note: nil
					),
					RecipeSetting(
						id: "waterfalls-shutter",
						label: "Shutter Speed",
						value: "1/2–2 s",
						note: "Adjust based on how much motion blur you want."
					)
				],
				requirements: [],
				tips: [],
				gearProfile: RecipeGearProfile(
					focalLengthMin: 16,
					focalLengthMax: 35,
					idealFocalLengthMin: 16,
					idealFocalLengthMax: 24,
					preferredCoverage: nil,
					minimumMaxAperture: nil,
					apertureImportance: 0.0,
					requiresTripod: true,
					recommendsNDFilter: true,
					recommendsCPLFilter: true,
					recommendsFlash: false
				),
				relatedReferenceIDs: [
					"shutter-speed",
					"aperture",
					"iso"
				]
			)
		)
	}
	.environment(
		QuickReferenceCatalog()
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
