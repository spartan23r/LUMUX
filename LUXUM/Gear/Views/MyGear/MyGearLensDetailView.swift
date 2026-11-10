//
//  MyGearLensDetailView.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import SwiftUI

struct MyGearLensDetailView: View {
	
	// MARK: - properties
	@Environment(GearCatalog.self) private var gearCatalog
	@Environment(RecipeCatalog.self) private var recipeCatalog

	var ownedItem: OwnedGearItem

	private let gearMatcher = RecipeGearMatcher()
	
	@State private var nickname: String
	@State private var paidPrice: String
	@State private var notes: String

	private var suggestedRecipes: [Recipe] {
		guard let lens = ownedItem.lens(in: gearCatalog) else {
			return []
		}
		
		return gearMatcher.bestMatchingRecipes(
			for: lens,
			recipes: recipeCatalog.recipes,
			limit: 4
		)
	}
	
	// MARK: - init
	init(ownedItem: OwnedGearItem) {
		self.ownedItem = ownedItem
		_nickname = State(initialValue: ownedItem.nickname ?? "")
		_paidPrice = State(initialValue: Self.paidPriceText(ownedItem.paidPrice))
		_notes = State(initialValue: ownedItem.notes ?? "")
	}
	
	// MARK: - body
	var body: some View {
		List {
			if let lens = ownedItem.lens(in: gearCatalog) {
				Section("General") {
					
					if let brand = gearCatalog.brand(for: lens.brandID) {
						LabeledContent("Brand", value: brand.name)
					}
					
					LabeledContent("Name", value: lens.name)
					
					if let family = lens.family {
						LabeledContent("Family", value: family)
					}
					
					if let series = lens.series {
						LabeledContent("Series", value: series)
					}
					
					if let releaseYear = lens.releaseYear {
						LabeledContent("Release Year", value: String(releaseYear))
					}
				}
				
				Section("Compatibility") {
					LabeledContent("Mount", value: gearCatalog.mount(for: lens.mountID)?.name ?? lens.mountID)
					LabeledContent("Coverage", value: lens.coverage.displayName)
				}
				
				Section("Optics") {
					
					LabeledContent(
						"Focal Length",
						value: focalLengthText(
							min: lens.focalLengthMin,
							max: lens.focalLengthMax
						)
					)
					
					LabeledContent(
						"Max Aperture",
						value: apertureText(
							wide: lens.maxApertureWide,
							tele: lens.maxApertureTele
						)
					)
					
					if lens.minimumFocusDistance != nil ||
						lens.maximumMagnification != nil {
						
						if let minimumFocusDistance =
							lens.minimumFocusDistance {
							
							LabeledContent("Minimum Focus Distance", value: distanceText(minimumFocusDistance))
						}
						
						if let maximumMagnification =
							lens.maximumMagnification {
							
							LabeledContent("Maximum Magnification", value: magnificationText(maximumMagnification))
						}
						
					}
					
				}
				
				Section("Features") {
					LabeledContent("Optical Stabilization", value: lens.hasOIS ? "Yes" : "No")
					
					if let weatherSealed = lens.weatherSealed {
						LabeledContent("Weather Sealed", value: weatherSealed ? "Yes" : "No")
					}
					
					if let filterDiameter = lens.filterDiameter {
						LabeledContent("Filter Diameter", value: "\(formatted(filterDiameter)) mm")
					}
				}
				
				if let discontinued = lens.discontinued {
					Section {
						LabeledContent("Discontinued", value: discontinued ? "Yes" : "No")
					}
				}
				
				if !suggestedRecipes.isEmpty {
					Section("Great For") {
						ForEach(suggestedRecipes) { recipe in
							NavigationLink {
								RecipesDetailView(
									recipe: recipe
								)
							} label: {
								HStack(
									spacing: 12
								) {
									Image(systemName: recipe.systemImage)
										.foregroundStyle(.tint)
										.frame(width: 24)
									
									VStack(
										alignment: .leading,
										spacing: 2
									) {
										Text(recipe.title)
											.foregroundStyle(.primary)
										
										Text(recipe.subtitle)
											.font(.caption)
											.foregroundStyle(.secondary)
									}
								}
							}
						}
					}
				}
				
				Section("Paid Price") {
					HStack(spacing: 4) {
						Text(Locale.current.currencySymbol ?? "")
							.foregroundStyle(.secondary)

						TextField(
							"0\(Locale.current.decimalSeparator ?? ",")00",
							text: $paidPrice
						)
						.keyboardType(.decimalPad)
					}
				}
				
				Section("Nickname") {
					TextField("Add nickname", text: $nickname)
						.textInputAutocapitalization(.words)
				}
				
				Section("Notes") {
					TextField("Add notes", text: $notes, axis: .vertical)
						.textInputAutocapitalization(.sentences)
				}
				
			}
		}
		.navigationTitle("My Gear")
		.navigationSubtitle("Lens")
		.scrollEdgeEffectStyle(.soft, for: .top)
		.toolbarTitleDisplayMode(.inline)
		.scrollDismissesKeyboard(.interactively)
		.onDisappear {
			saveNickname()
			savePaidPrice()
			saveNotes()
		}
	}
}

// MARK: - actions
private extension MyGearLensDetailView {
	
	func saveNickname() {
		let trimmedNickname = nickname.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		nickname = trimmedNickname
		
		ownedItem.nickname = trimmedNickname.isEmpty
			? nil
			: trimmedNickname
	}
	
	func savePaidPrice() {
		let trimmedPrice = paidPrice.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		guard !trimmedPrice.isEmpty else {
			paidPrice = ""
			ownedItem.paidPrice = nil
			return
		}
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = Locale.current
		
		guard let number = formatter.number(from: trimmedPrice) else {
			paidPrice = Self.paidPriceText(ownedItem.paidPrice)
			return
		}
		
		let value = number.doubleValue
		
		guard value >= 0 else {
			paidPrice = Self.paidPriceText(ownedItem.paidPrice)
			return
		}
		
		ownedItem.paidPrice = value
		paidPrice = Self.paidPriceText(value)
	}
	
	func saveNotes() {
		let trimmedNotes = notes.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		notes = trimmedNotes
		
		ownedItem.notes = trimmedNotes.isEmpty
			? nil
			: trimmedNotes
	}
}


// MARK: - Formatters
private extension MyGearLensDetailView {
	
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
	
	func magnificationText(_ value: Double) -> String {
		"\(formatted(value))x"
	}
	
	func distanceText(_ value: Double) -> String {
		"\(formatted(value)) m"
	}
	static func paidPriceText(_ value: Double?) -> String {
		guard let value else {
			return ""
		}
		
		return value.formatted(
			.number
				.locale(Locale.current)
				.precision(.fractionLength(0...2))
		)
	}

}

#Preview {
	MyGearLensDetailView(ownedItem: OwnedGearItem(catalogID: "sony-e-16-55mm-f2-8-g", kind: .lens))
}
