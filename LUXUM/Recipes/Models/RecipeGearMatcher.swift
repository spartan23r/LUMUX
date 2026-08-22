//
//  RecipeGearMatcher.swift
//  LUXUM
//
//  Camera-aware recipe ↔ gear matching
//

import Foundation

struct RecipeGearMatcher {

	// MARK: - lens match result

	struct LensMatch {
		let lens: LensCatalogItem
		let camera: CameraCatalogItem?

		let score: Double
		let quality: LensMatchQuality
		let reason: String

		let equivalentFocalLengthMin: Double
		let equivalentFocalLengthMax: Double
		let effectiveMaxAperture: Double
	}

	enum LensMatchQuality: Int, Comparable {
		case usable = 0
		case good = 1
		case excellent = 2

		static func < (
			lhs: LensMatchQuality,
			rhs: LensMatchQuality
		) -> Bool {
			lhs.rawValue < rhs.rawValue
		}

		var title: String {
			switch self {
			case .excellent:
				return "Excellent match"
			case .good:
				return "Good match"
			case .usable:
				return "Usable"
			}
		}
	}


	// MARK: - lens matching

	func lensMatches(
		for recipe: Recipe,
		ownedGear: [OwnedGearItem],
		gearCatalog: GearCatalog
	) -> [LensMatch] {
		guard let profile = recipe.gearProfile else {
			return []
		}

		let ownedCameras = ownedGear
			.filter { $0.kind == .camera }
			.compactMap { $0.camera(in: gearCatalog) }

		let ownedLenses = ownedGear
			.filter { $0.kind == .lens }
			.compactMap { $0.lens(in: gearCatalog) }

		return ownedLenses
			.compactMap { lens in
				bestMatch(
					for: lens,
					cameras: ownedCameras,
					profile: profile
				)
			}
			.sorted { lhs, rhs in
				if abs(lhs.score - rhs.score) < 0.001 {
					if lhs.quality != rhs.quality {
						return lhs.quality > rhs.quality
					}

					return lhs.lens.name.localizedStandardCompare(
						rhs.lens.name
					) == .orderedAscending
				}

				return lhs.score > rhs.score
			}
	}

	func matchingLenses(
		for recipe: Recipe,
		ownedGear: [OwnedGearItem],
		gearCatalog: GearCatalog
	) -> [LensCatalogItem] {
		lensMatches(
			for: recipe,
			ownedGear: ownedGear,
			gearCatalog: gearCatalog
		)
		.map(\.lens)
	}

	func bestLensMatch(
		for recipe: Recipe,
		ownedGear: [OwnedGearItem],
		gearCatalog: GearCatalog
	) -> LensMatch? {
		lensMatches(
			for: recipe,
			ownedGear: ownedGear,
			gearCatalog: gearCatalog
		)
		.first
	}

	func bestMatchingLens(
		for recipe: Recipe,
		ownedGear: [OwnedGearItem],
		gearCatalog: GearCatalog
	) -> LensCatalogItem? {
		bestLensMatch(
			for: recipe,
			ownedGear: ownedGear,
			gearCatalog: gearCatalog
		)?
		.lens
	}

	func alternativeMatchingLenses(
		for recipe: Recipe,
		ownedGear: [OwnedGearItem],
		gearCatalog: GearCatalog
	) -> [LensCatalogItem] {
		Array(
			matchingLenses(
				for: recipe,
				ownedGear: ownedGear,
				gearCatalog: gearCatalog
			)
			.dropFirst()
		)
	}


	// MARK: - filter matching

	func ownedNDFilter(
		in ownedFilters: [OwnedFilter]
	) -> OwnedFilter? {
		ownedFilters.first {
			$0.kind == .nd ||
			$0.kind == .variableND
		}
	}

	func ownedCPLFilter(
		in ownedFilters: [OwnedFilter]
	) -> OwnedFilter? {
		ownedFilters.first {
			$0.kind == .cpl
		}
	}


	// MARK: - accessory matching

	func ownedTripod(
		in ownedAccessories: [OwnedAccessory]
	) -> OwnedAccessory? {
		ownedAccessories.first {
			$0.kind == .tripod
		}
	}

	func ownedFlash(
		in ownedAccessories: [OwnedAccessory]
	) -> OwnedAccessory? {
		ownedAccessories.first {
			$0.kind == .flash
		}
	}


	// MARK: - recipe matching

	func hasMatchingGear(
		for recipe: Recipe,
		ownedGear: [OwnedGearItem],
		ownedFilters: [OwnedFilter],
		ownedAccessories: [OwnedAccessory],
		gearCatalog: GearCatalog
	) -> Bool {
		let lensMatch = bestLensMatch(
			for: recipe,
			ownedGear: ownedGear,
			gearCatalog: gearCatalog
		) != nil

		let filterMatch = hasRecommendedFilter(
			for: recipe,
			ownedFilters: ownedFilters
		)

		let accessoryMatch = hasRecommendedAccessory(
			for: recipe,
			ownedAccessories: ownedAccessories
		)

		return lensMatch ||
			filterMatch ||
			accessoryMatch
	}

	func gearMatchScore(
		for recipe: Recipe,
		ownedGear: [OwnedGearItem],
		ownedFilters: [OwnedFilter],
		ownedAccessories: [OwnedAccessory],
		gearCatalog: GearCatalog
	) -> Double {
		guard let profile = recipe.gearProfile else {
			return 0
		}

		var score = 0.0

		if let bestLensMatch = bestLensMatch(
			for: recipe,
			ownedGear: ownedGear,
			gearCatalog: gearCatalog
		) {
			score += bestLensMatch.score
		}

		if profile.recommendsNDFilter,
		   ownedNDFilter(in: ownedFilters) != nil {
			score += 15
		}

		if profile.recommendsCPLFilter,
		   ownedCPLFilter(in: ownedFilters) != nil {
			score += 10
		}

		if profile.requiresTripod,
		   ownedTripod(in: ownedAccessories) != nil {
			score += 20
		}

		if profile.recommendsFlash,
		   ownedFlash(in: ownedAccessories) != nil {
			score += 15
		}

		return score
	}


	// MARK: - recipe suggestions for a lens

	/// Legacy overload kept so existing My Gear detail screens continue to compile.
	/// This scores the lens without camera crop-factor information.
	func matchingRecipes(
		for lens: LensCatalogItem,
		recipes: [Recipe]
	) -> [Recipe] {
		recipes
			.compactMap { recipe -> (recipe: Recipe, score: Double)? in
				guard let profile = recipe.gearProfile else {
					return nil
				}

				let context = LensContext(
					lens: lens,
					camera: nil,
					cropFactor: 1,
					equivalentMin: lens.focalLengthMin,
					equivalentMax: lens.focalLengthMax
				)

				guard isUsable(
					context,
					profile: profile
				) else {
					return nil
				}

				return (
					recipe,
					matchScore(
						for: context,
						profile: profile
					)
				)
			}
			.sorted {
				$0.score > $1.score
			}
			.map(\.recipe)
	}

	func bestMatchingRecipes(
		for lens: LensCatalogItem,
		recipes: [Recipe],
		limit: Int = 4
	) -> [Recipe] {
		Array(
			matchingRecipes(
				for: lens,
				recipes: recipes
			)
			.prefix(limit)
		)
	}

	/// Camera-aware overload for future / updated My Gear lens detail screens.
	func matchingRecipes(
		for lens: LensCatalogItem,
		camera: CameraCatalogItem?,
		recipes: [Recipe]
	) -> [Recipe] {
		let context = lensContext(
			for: lens,
			camera: camera
		)

		return recipes
			.compactMap { recipe -> (recipe: Recipe, score: Double)? in
				guard let profile = recipe.gearProfile else {
					return nil
				}

				guard isUsable(
					context,
					profile: profile
				) else {
					return nil
				}

				return (
					recipe,
					matchScore(
						for: context,
						profile: profile
					)
				)
			}
			.sorted {
				$0.score > $1.score
			}
			.map(\.recipe)
	}

	func bestMatchingRecipes(
		for lens: LensCatalogItem,
		camera: CameraCatalogItem?,
		recipes: [Recipe],
		limit: Int = 4
	) -> [Recipe] {
		Array(
			matchingRecipes(
				for: lens,
				camera: camera,
				recipes: recipes
			)
			.prefix(limit)
		)
	}


	// MARK: - filter / accessory recipe suggestions

	func matchingRecipes(
		for filter: OwnedFilter,
		recipes: [Recipe]
	) -> [Recipe] {
		recipes.filter { recipe in
			guard let profile = recipe.gearProfile else {
				return false
			}

			switch filter.kind {
			case .nd, .variableND:
				return profile.recommendsNDFilter

			case .cpl:
				return profile.recommendsCPLFilter

			default:
				return false
			}
		}
	}

	func matchingRecipes(
		for accessory: OwnedAccessory,
		recipes: [Recipe]
	) -> [Recipe] {
		recipes.filter { recipe in
			guard let profile = recipe.gearProfile else {
				return false
			}

			switch accessory.kind {
			case .tripod:
				return profile.requiresTripod

			case .flash:
				return profile.recommendsFlash

			default:
				return false
			}
		}
	}
}


// MARK: - camera-aware lens pairing
private extension RecipeGearMatcher {

	struct LensContext {
		let lens: LensCatalogItem
		let camera: CameraCatalogItem?
		let cropFactor: Double
		let equivalentMin: Double
		let equivalentMax: Double
	}

	func bestMatch(
		for lens: LensCatalogItem,
		cameras: [CameraCatalogItem],
		profile: RecipeGearProfile
	) -> LensMatch? {
		let compatibleCameras = cameras.filter {
			isCompatible(
				lens: lens,
				camera: $0
			)
		}

		// If the user has no compatible body stored, keep the lens usable.
		// We then fall back to its native focal length instead of hiding it.
		let contexts: [LensContext]

		if compatibleCameras.isEmpty {
			contexts = [
				lensContext(
					for: lens,
					camera: nil
				)
			]
		} else {
			contexts = compatibleCameras.map {
				lensContext(
					for: lens,
					camera: $0
				)
			}
		}

		return contexts
			.compactMap { context -> LensMatch? in
				guard isUsable(
					context,
					profile: profile
				) else {
					return nil
				}

				let score = matchScore(
					for: context,
					profile: profile
				)

				let effectiveAperture = effectiveMaxAperture(
					for: context,
					profile: profile
				)

				return LensMatch(
					lens: lens,
					camera: context.camera,
					score: score,
					quality: matchQuality(
						for: context,
						profile: profile
					),
					reason: matchReason(
						for: context,
						profile: profile
					),
					equivalentFocalLengthMin: context.equivalentMin,
					equivalentFocalLengthMax: context.equivalentMax,
					effectiveMaxAperture: effectiveAperture
				)
			}
			.max {
				$0.score < $1.score
			}
	}

	func isCompatible(
		lens: LensCatalogItem,
		camera: CameraCatalogItem
	) -> Bool {
		guard let cameraMountID = camera.mountID else {
			return false
		}

		return cameraMountID == lens.mountID
	}

	func lensContext(
		for lens: LensCatalogItem,
		camera: CameraCatalogItem?
	) -> LensContext {
		let cropFactor = effectiveCropFactor(
			lens: lens,
			camera: camera
		)

		return LensContext(
			lens: lens,
			camera: camera,
			cropFactor: cropFactor,
			equivalentMin: lens.focalLengthMin * cropFactor,
			equivalentMax: lens.focalLengthMax * cropFactor
		)
	}

	/// Recipes use 35 mm-equivalent focal-length ranges.
	///
	/// The camera crop factor is used normally. If a smaller-format lens is
	/// mounted on a larger-format body, the lens coverage becomes the limiting
	/// format (for example an APS-C lens used in crop mode on a full-frame body).
	func effectiveCropFactor(
		lens: LensCatalogItem,
		camera: CameraCatalogItem?
	) -> Double {
		guard let camera else {
			return 1
		}

		return max(
			camera.cropFactor,
			defaultCropFactor(
				for: lens.coverage
			)
		)
	}

	func defaultCropFactor(
		for coverage: LensCoverage
	) -> Double {
		switch coverage {
		case .mediumFormat:
			return 0.79
		case .fullFrame:
			return 1.0
		case .apsH:
			return 1.3
		case .apsC:
			return 1.5
		case .fourThirds:
			return 2.0
		}
	}
}


// MARK: - lens scoring
private extension RecipeGearMatcher {

	func isUsable(
		_ context: LensContext,
		profile: RecipeGearProfile
	) -> Bool {
		guard matchesCoverage(
			context.lens,
			profile: profile
		) else {
			return false
		}

		return hasRequiredFocalOverlap(
			context,
			profile: profile
		)
	}

	func hasRequiredFocalOverlap(
		_ context: LensContext,
		profile: RecipeGearProfile
	) -> Bool {
		guard
			let requiredMin = profile.focalLengthMin,
			let requiredMax = profile.focalLengthMax
		else {
			return true
		}

		return context.equivalentMax >= requiredMin &&
			context.equivalentMin <= requiredMax
	}

	func matchesCoverage(
		_ lens: LensCatalogItem,
		profile: RecipeGearProfile
	) -> Bool {
		guard let preferredCoverage = profile.preferredCoverage else {
			return true
		}

		return lens.coverage == preferredCoverage
	}

	func matchScore(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> Double {
		var score = 0.0

		// 45 points: how well the lens covers the recipe's usable focal range.
		score += requiredFocalScore(
			for: context,
			profile: profile
		)

		// 40 points: reward coverage of the recipe's actual sweet spot.
		score += idealFocalScore(
			for: context,
			profile: profile
		)

		// Up to roughly 30 points for aperture-sensitive recipes.
		score += apertureScore(
			for: context,
			profile: profile
		)

		// A small preference for a lens specifically intended for the requested
		// coverage, when the recipe provides one.
		if let preferredCoverage = profile.preferredCoverage,
		   context.lens.coverage == preferredCoverage {
			score += 8
		}

		return max(score, 0)
	}

	func requiredFocalScore(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> Double {
		guard
			let requiredMin = profile.focalLengthMin,
			let requiredMax = profile.focalLengthMax
		else {
			return 30
		}

		guard context.equivalentMax >= requiredMin,
			  context.equivalentMin <= requiredMax else {
			return 0
		}

		if isPrime(context.lens) {
			return context.equivalentMin >= requiredMin &&
				context.equivalentMin <= requiredMax
				? 40
				: 0
		}

		let ratio = overlapRatio(
			lensMin: context.equivalentMin,
			lensMax: context.equivalentMax,
			targetMin: requiredMin,
			targetMax: requiredMax
		)

		return 15 + (30 * ratio)
	}

	func idealFocalScore(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> Double {
		guard
			let idealMin = profile.idealFocalLengthMin,
			let idealMax = profile.idealFocalLengthMax
		else {
			return 0
		}

		guard context.equivalentMax >= idealMin,
			  context.equivalentMin <= idealMax else {
			return 0
		}

		if isPrime(context.lens) {
			return context.equivalentMin >= idealMin &&
				context.equivalentMin <= idealMax
				? 40
				: 0
		}

		let ratio = overlapRatio(
			lensMin: context.equivalentMin,
			lensMax: context.equivalentMax,
			targetMin: idealMin,
			targetMax: idealMax
		)

		return 40 * ratio
	}

	func apertureScore(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> Double {
		guard
			let requiredAperture = profile.minimumMaxAperture,
			let importance = profile.apertureImportance,
			importance > 0
		else {
			return 0
		}

		let lensAperture = effectiveMaxAperture(
			for: context,
			profile: profile
		)

		if lensAperture <= requiredAperture {
			let advantage = requiredAperture - lensAperture
			let base = 12 * importance
			let bonus = min(
				advantage * 8 * importance,
				20
			)

			return base + bonus
		}

		let deficit = lensAperture - requiredAperture

		return -(10 + deficit * 12) * importance
	}

	/// Uses the aperture the zoom is likely to have around the recipe's ideal
	/// focal length instead of always treating a variable-aperture zoom as if
	/// it were at its wide-end aperture.
	func effectiveMaxAperture(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> Double {
		let lens = context.lens

		guard lens.focalLengthMax > lens.focalLengthMin else {
			return lens.maxApertureWide
		}

		guard lens.maxApertureTele != lens.maxApertureWide else {
			return lens.maxApertureWide
		}

		let targetEquivalent: Double = {
			if
				let idealMin = profile.idealFocalLengthMin,
				let idealMax = profile.idealFocalLengthMax
			{
				let overlapMin = max(
					context.equivalentMin,
					idealMin
				)
				let overlapMax = min(
					context.equivalentMax,
					idealMax
				)

				if overlapMax >= overlapMin {
					return (overlapMin + overlapMax) / 2
				}
			}

			if
				let requiredMin = profile.focalLengthMin,
				let requiredMax = profile.focalLengthMax
			{
				let overlapMin = max(
					context.equivalentMin,
					requiredMin
				)
				let overlapMax = min(
					context.equivalentMax,
					requiredMax
				)

				if overlapMax >= overlapMin {
					return (overlapMin + overlapMax) / 2
				}
			}

			return (context.equivalentMin + context.equivalentMax) / 2
		}()

		let targetPhysical = targetEquivalent / context.cropFactor

		let progress = min(
			max(
				(targetPhysical - lens.focalLengthMin) /
				(lens.focalLengthMax - lens.focalLengthMin),
				0
			),
			1
		)

		return lens.maxApertureWide +
			((lens.maxApertureTele - lens.maxApertureWide) * progress)
	}

	func matchQuality(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> LensMatchQuality {
		let idealOverlap = idealOverlapRatio(
			for: context,
			profile: profile
		)

		let requiredOverlap = requiredOverlapRatio(
			for: context,
			profile: profile
		)

		let apertureMeetsRecommendation: Bool = {
			guard let required = profile.minimumMaxAperture else {
				return true
			}

			return effectiveMaxAperture(
				for: context,
				profile: profile
			) <= required
		}()

		if idealOverlap >= 0.65 &&
			apertureMeetsRecommendation {
			return .excellent
		}

		if requiredOverlap >= 0.40 &&
			apertureMeetsRecommendation {
			return .good
		}

		return .usable
	}

	func matchReason(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> String {
		let lens = context.lens
		let cameraSuffix: String = {
			guard let camera = context.camera else {
				return ""
			}

			return " on \(camera.name)"
		}()

		let equivalentDescription = formatRange(
			context.equivalentMin,
			context.equivalentMax
		)

		let isPrimeLens = isPrime(lens)
		let primeEquivalent = format(
			context.equivalentMin
		)

		if
			let requiredAperture = profile.minimumMaxAperture
		{
			let effectiveAperture = effectiveMaxAperture(
				for: context,
				profile: profile
			)

			if effectiveAperture > requiredAperture {
				if isPrimeLens {
					return "Its \(primeEquivalent) mm equivalent focal length\(cameraSuffix) fits this recipe, but F\(format(effectiveAperture)) is slower than the recommended F\(format(requiredAperture))."
				}

				return "Provides about \(equivalentDescription) equivalent\(cameraSuffix), but F\(format(effectiveAperture)) is slower than the recommended F\(format(requiredAperture))."
			}
		}

		// Prime lenses provide one focal length, so never describe them
		// as covering an entire focal-length range.
		if isPrimeLens {
			if
				let idealMin = profile.idealFocalLengthMin,
				let idealMax = profile.idealFocalLengthMax,
				context.equivalentMin >= idealMin,
				context.equivalentMin <= idealMax
			{
				return "Its \(primeEquivalent) mm equivalent focal length\(cameraSuffix) sits within the ideal \(formatRange(idealMin, idealMax)) range."
			}

			if
				let requiredMin = profile.focalLengthMin,
				let requiredMax = profile.focalLengthMax,
				context.equivalentMin >= requiredMin,
				context.equivalentMin <= requiredMax
			{
				return "Its \(primeEquivalent) mm equivalent focal length\(cameraSuffix) sits within the useful \(formatRange(requiredMin, requiredMax)) range."
			}

			return "Its \(primeEquivalent) mm equivalent focal length fits this recipe well\(cameraSuffix)."
		}

		let idealOverlap = idealOverlapRatio(
			for: context,
			profile: profile
		)

		if
			idealOverlap >= 0.95,
			let idealMin = profile.idealFocalLengthMin,
			let idealMax = profile.idealFocalLengthMax
		{
			return "Covers the full ideal \(formatRange(idealMin, idealMax)) equivalent range\(cameraSuffix)."
		}

		if
			idealOverlap > 0,
			let idealMin = profile.idealFocalLengthMin,
			let idealMax = profile.idealFocalLengthMax
		{
			return "Provides \(equivalentDescription) equivalent\(cameraSuffix) and overlaps the ideal \(formatRange(idealMin, idealMax)) range."
		}

		if
			let requiredMin = profile.focalLengthMin,
			let requiredMax = profile.focalLengthMax
		{
			return "Provides \(equivalentDescription) equivalent\(cameraSuffix), covering part of the useful \(formatRange(requiredMin, requiredMax)) range."
		}

		return "Its \(equivalentDescription) equivalent range fits the main lens requirements\(cameraSuffix)."
	}

	func requiredOverlapRatio(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> Double {
		guard
			let min = profile.focalLengthMin,
			let max = profile.focalLengthMax
		else {
			return 1
		}

		if isPrime(context.lens) {
			return context.equivalentMin >= min &&
				context.equivalentMin <= max
				? 1
				: 0
		}

		return overlapRatio(
			lensMin: context.equivalentMin,
			lensMax: context.equivalentMax,
			targetMin: min,
			targetMax: max
		)
	}

	func idealOverlapRatio(
		for context: LensContext,
		profile: RecipeGearProfile
	) -> Double {
		guard
			let min = profile.idealFocalLengthMin,
			let max = profile.idealFocalLengthMax
		else {
			return 0
		}

		if isPrime(context.lens) {
			return context.equivalentMin >= min &&
				context.equivalentMin <= max
				? 1
				: 0
		}

		return overlapRatio(
			lensMin: context.equivalentMin,
			lensMax: context.equivalentMax,
			targetMin: min,
			targetMax: max
		)
	}

	func overlapRatio(
		lensMin: Double,
		lensMax: Double,
		targetMin: Double,
		targetMax: Double
	) -> Double {
		let overlapMin = max(
			lensMin,
			targetMin
		)
		let overlapMax = min(
			lensMax,
			targetMax
		)

		guard overlapMax >= overlapMin else {
			return 0
		}

		let targetWidth = targetMax - targetMin

		guard targetWidth > 0 else {
			return overlapMax >= targetMin
				? 1
				: 0
		}

		return min(
			max(
				(overlapMax - overlapMin) / targetWidth,
				0
			),
			1
		)
	}

	func isPrime(
		_ lens: LensCatalogItem
	) -> Bool {
		abs(
			lens.focalLengthMax -
			lens.focalLengthMin
		) < 0.001
	}

	func formatRange(
		_ min: Double,
		_ max: Double
	) -> String {
		if abs(max - min) < 0.001 {
			return "\(format(min)) mm"
		}

		return "\(format(min))–\(format(max)) mm"
	}

	func format(
		_ value: Double
	) -> String {
		if abs(value.rounded() - value) < 0.05 {
			return String(Int(value.rounded()))
		}

		return String(
			format: "%.1f",
			value
		)
	}
}


// MARK: - supporting matching
private extension RecipeGearMatcher {

	func hasRecommendedFilter(
		for recipe: Recipe,
		ownedFilters: [OwnedFilter]
	) -> Bool {
		guard let profile = recipe.gearProfile else {
			return false
		}

		if profile.recommendsNDFilter,
		   ownedNDFilter(in: ownedFilters) != nil {
			return true
		}

		if profile.recommendsCPLFilter,
		   ownedCPLFilter(in: ownedFilters) != nil {
			return true
		}

		return false
	}

	func hasRecommendedAccessory(
		for recipe: Recipe,
		ownedAccessories: [OwnedAccessory]
	) -> Bool {
		guard let profile = recipe.gearProfile else {
			return false
		}

		if profile.requiresTripod,
		   ownedTripod(in: ownedAccessories) != nil {
			return true
		}

		if profile.recommendsFlash,
		   ownedFlash(in: ownedAccessories) != nil {
			return true
		}

		return false
	}
}
