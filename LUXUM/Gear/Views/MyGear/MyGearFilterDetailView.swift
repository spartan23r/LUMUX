//
//  MyGearFilterDetailView.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import SwiftUI
import SwiftData

struct MyGearFilterDetailView: View {
	
	// MARK: - properties
	@Bindable var filter: OwnedFilter
	
	@State private var brand: String
	@State private var name: String
	@State private var strength: String
	@State private var paidPrice: String
	@State private var notes: String
	
	@Environment(RecipeCatalog.self) private var recipeCatalog

	private let gearMatcher = RecipeGearMatcher()
	
	private var suggestedRecipes: [Recipe] {
		Array(
			gearMatcher.matchingRecipes(
				for: filter,
				recipes: recipeCatalog.recipes
			)
			.prefix(4)
		)
	}
	
	// MARK: - init
	init(filter: OwnedFilter) {
		self.filter = filter
		_brand = State(initialValue: filter.brand ?? "")
		_name = State(initialValue: filter.name)
		_strength = State(initialValue: filter.strength ?? "")
		_paidPrice = State(initialValue: Self.paidPriceText(filter.paidPrice))
		_notes = State(initialValue: filter.notes ?? "")
	}
	
	// MARK: - body
	var body: some View {
		List {
			Section("General") {
				
				LabeledContent("Brand") {

					TextField(
						"Brand",
						text: $brand
					)
					.textInputAutocapitalization(.words)
					.multilineTextAlignment(.trailing)
					.onSubmit {
						saveBrand()
					}

				}
				
				LabeledContent("Name") {

					TextField(
						"Name",
						text: $name
					)
					.textInputAutocapitalization(.words)
					.multilineTextAlignment(.trailing)
					.onSubmit {
						saveName()
					}

				}
				
				Picker(
					"Type",
					selection: kindBinding
				) {
					ForEach(
						FilterKind.allCases,
						id: \.self
					) { kind in
						Text(kind.title)
							.tag(kind)
					}
				}
				.tint(.accent)
			}
			
			Section("Specifications") {
				
				LabeledContent("Diameter") {
					HStack(spacing: 4) {
						TextField(
							"72",
							text: diameterBinding
						)
						.keyboardType(.numberPad)
						.multilineTextAlignment(.trailing)
						
						Text("mm")
							.foregroundStyle(.secondary)
					}
				}
				
				LabeledContent("Strength") {

					TextField(
						"e.g. 2–8 stops",
						text: $strength
					)
					.textInputAutocapitalization(.words)
					.multilineTextAlignment(.trailing)

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
			Section("Notes") {
				TextField(
					"Add notes",
					text: $notes,
					axis: .vertical
				)
				.textInputAutocapitalization(.sentences)
			}
			
		}
		.navigationTitle("My Gear")
		.navigationSubtitle("Filter")
		.navigationBarTitleDisplayMode(.inline)
		.scrollDismissesKeyboard(.interactively)
		.onDisappear {
			saveName()
			saveBrand()
			saveStrength()
			savePaidPrice()
			saveNotes()
		}
	}
}


// MARK: - bindings
private extension MyGearFilterDetailView {
	
	var kindBinding: Binding<FilterKind> {
		Binding(
			get: {
				filter.kind
			},
			set: { newValue in
				filter.kindRawValue = newValue.rawValue
			}
		)
	}
	
	var diameterBinding: Binding<String> {
		Binding(
			get: {
				if let diameter = filter.diameter {
					return String(diameter)
				}
				
				return ""
			},
			set: { newValue in
				let digitsOnly = newValue.filter(\.isNumber)
				
				filter.diameter = Int(digitsOnly)
			}
		)
	}
}


// MARK: - actions
private extension MyGearFilterDetailView {
	
	func saveName() {
		let trimmedName = name.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		guard !trimmedName.isEmpty else {
			name = filter.name
			return
		}
		
		name = trimmedName
		filter.name = trimmedName
	}
	
	func saveBrand() {
		let trimmedBrand = brand.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		brand = trimmedBrand
		
		filter.brand = trimmedBrand.isEmpty
			? nil
			: trimmedBrand
	}
	
	func saveStrength() {
		let trimmedStrength = strength.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		strength = trimmedStrength
		
		filter.strength = trimmedStrength.isEmpty
			? nil
			: trimmedStrength
	}
	
	func savePaidPrice() {
		let trimmedPrice = paidPrice.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		guard !trimmedPrice.isEmpty else {
			paidPrice = ""
			filter.paidPrice = nil
			return
		}
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = Locale.current
		
		guard let number = formatter.number(from: trimmedPrice) else {
			paidPrice = Self.paidPriceText(filter.paidPrice)
			return
		}
		
		let value = number.doubleValue
		
		guard value >= 0 else {
			paidPrice = Self.paidPriceText(filter.paidPrice)
			return
		}
		
		filter.paidPrice = value
		paidPrice = Self.paidPriceText(value)
	}
	
	func saveNotes() {
		let trimmedNotes = notes.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		notes = trimmedNotes
		
		filter.notes = trimmedNotes.isEmpty
			? nil
			: trimmedNotes
	}
}



// MARK: - formatters
private extension MyGearFilterDetailView {

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
	NavigationStack {
		MyGearFilterDetailView(
			filter: OwnedFilter(
				name: "Nuances Variable ND",
				brand: "Cokin",
				kind: .variableND,
				diameter: 72,
				strength: "2–8 stops"
			)
		)
	}
	.environment(RecipeCatalog())
	.modelContainer(
		for: OwnedFilter.self,
		inMemory: true
	)
}
