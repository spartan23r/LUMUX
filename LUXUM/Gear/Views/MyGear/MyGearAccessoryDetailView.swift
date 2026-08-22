//
//  MyGearAccessoryDetailView.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import SwiftUI
import SwiftData

struct MyGearAccessoryDetailView: View {
	
	// MARK: - properties
	@Bindable var accessory: OwnedAccessory
	
	@State private var brand: String
	@State private var name: String
	@State private var paidPrice: String
	@State private var notes: String
	@State private var isShowingAccessoriesTypeInfo = false
	
	@Environment(RecipeCatalog.self)private var recipeCatalog

	private let gearMatcher = RecipeGearMatcher()
	
	private var suggestedRecipes: [Recipe] {
		Array(
			gearMatcher.matchingRecipes(
				for: accessory,
				recipes: recipeCatalog.recipes
			)
			.prefix(4)
		)
	}
	
	// MARK: - init
	init(accessory: OwnedAccessory) {
		self.accessory = accessory
		_brand = State(initialValue: accessory.brand ?? "")
		_name = State(initialValue: accessory.name)
		_paidPrice = State(initialValue: Self.paidPriceText(accessory.paidPrice))
		_notes = State(initialValue: accessory.notes ?? "")
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
				
				HStack {
					
					Button {
						isShowingAccessoriesTypeInfo = true
					} label: {
						HStack {
							Text("Type")
							Image(systemName: "info.circle")
								.foregroundStyle(.accent)
						}
					}
					.buttonStyle(.plain)

					Spacer(minLength: 12)

					Picker(
						"Type",
						selection: kindBinding
					) {
						ForEach(
							AccessoryKind.allCases,
							id: \.self
						) { kind in
							Text(kind.title)
								.tag(kind)
						}
					}
					.tint(.accent)
					.labelsHidden()
					.fixedSize(horizontal: true, vertical: false)
					.layoutPriority(1)
					
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
		.navigationSubtitle("Accessory")
		.navigationBarTitleDisplayMode(.inline)
		.scrollDismissesKeyboard(.interactively)
		.sheet(isPresented: $isShowingAccessoriesTypeInfo) {
			MyGearAccessoryTypeInfoView(dismiss: $isShowingAccessoriesTypeInfo)
		}
		.onDisappear {
			saveName()
			saveBrand()
			savePaidPrice()
			saveNotes()
		}
	}
}


// MARK: - bindings
private extension MyGearAccessoryDetailView {
	
	var kindBinding: Binding<AccessoryKind> {
		Binding(
			get: {
				accessory.kind
			},
			set: { newValue in
				accessory.kindRawValue = newValue.rawValue
			}
		)
	}
}


// MARK: - actions
private extension MyGearAccessoryDetailView {
	
	func saveName() {
		let trimmedName = name.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		guard !trimmedName.isEmpty else {
			name = accessory.name
			return
		}
		
		name = trimmedName
		accessory.name = trimmedName
	}
	
	func saveBrand() {
		let trimmedBrand = brand.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		brand = trimmedBrand
		
		accessory.brand = trimmedBrand.isEmpty
			? nil
			: trimmedBrand
	}
	
	func savePaidPrice() {
		let trimmedPrice = paidPrice.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		guard !trimmedPrice.isEmpty else {
			paidPrice = ""
			accessory.paidPrice = nil
			return
		}
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = Locale.current
		
		guard let number = formatter.number(from: trimmedPrice) else {
			paidPrice = Self.paidPriceText(accessory.paidPrice)
			return
		}
		
		let value = number.doubleValue
		
		guard value >= 0 else {
			paidPrice = Self.paidPriceText(accessory.paidPrice)
			return
		}
		
		accessory.paidPrice = value
		paidPrice = Self.paidPriceText(value)
	}
	
	func saveNotes() {
		let trimmedNotes = notes.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		notes = trimmedNotes
		
		accessory.notes = trimmedNotes.isEmpty
			? nil
			: trimmedNotes
	}
}



// MARK: - formatters
private extension MyGearAccessoryDetailView {

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
		MyGearAccessoryDetailView(
			accessory: OwnedAccessory(
				name: "3T-35K TableTop",
				brand: "Sirui",
				kind: .tripod
			)
		)
	}
	.environment(RecipeCatalog())
	.modelContainer(
		for: OwnedAccessory.self,
		inMemory: true
	)
}
