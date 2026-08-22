//
//  GearCatalogAddFilterView.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import SwiftUI
import SwiftData

struct GearCatalogAddFilterView: View {
	
	// MARK: - properties
	@Binding var dismiss: Bool
	
	@Environment(\.modelContext) private var modelContext
	
	@State private var brand = ""
	@State private var name = ""
	@State private var selectedKind: FilterKind = .variableND
	@State private var diameter = ""
	@State private var strength = ""
	
	@Environment(SettingsStore.self) private var settingsStore
	@State private var hapticSaved = false
	
	// MARK: - computed properties
	private var canSave: Bool {
		!name.trimmingCharacters(
			in: .whitespacesAndNewlines
		).isEmpty
	}
	
	private var parsedDiameter: Int? {
		guard !diameter.isEmpty else {
			return nil
		}
		
		return Int(diameter.trimmingCharacters(in: .whitespacesAndNewlines))
	}
	
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			Form {
				Section {
					
					LabeledContent("Brand") {
						
						TextField(
							"Brand",
							text: $brand
						)
						.textInputAutocapitalization(.words)
						.multilineTextAlignment(.trailing)
						
					}
					
					LabeledContent {
						
						TextField(
							"Name",
							text: $name
						)
						.textInputAutocapitalization(.words)
						.multilineTextAlignment(.trailing)
						
					} label: {
						HStack {
							Text("Name")
							Text("*")
								.foregroundStyle(.red)
						}
					}
					
					Picker(
						"Type",
						selection: $selectedKind
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
					
				} header: {
					Text("General")
				} footer: {
					Text("* Required")
				}
				
				Section("Specifications") {
					
					LabeledContent("Diameter") {
						HStack(spacing: 4) {
							TextField(
								"72",
								text: $diameter
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
			}
			.navigationTitle("Add Filter")
			.navigationBarTitleDisplayMode(.inline)
			.scrollDismissesKeyboard(.interactively)
			.toolbar {
				ToolbarItem(
					placement: .cancellationAction
				) {
					Button(role: .cancel) {
						dismiss = false
					}
				}
				
				ToolbarItem(
					placement: .confirmationAction
				) {
					Button(role: .confirm) {
						addFilter()
					}
					.disabled(!canSave)
				}
			}
			.sensoryFeedback(.success, trigger: hapticSaved)
			.interactiveDismissDisabled()
		}
	}
}


// MARK: - actions
private extension GearCatalogAddFilterView {
	
	func addFilter() {
		let trimmedName = name.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		let trimmedBrand = brand.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		let trimmedStrength = strength.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		let filter = OwnedFilter(
			name: trimmedName,
			brand: trimmedBrand.isEmpty
				? nil
				: trimmedBrand,
			kind: selectedKind,
			diameter: parsedDiameter,
			strength: trimmedStrength.isEmpty
				? nil
				: trimmedStrength
		)
		
		modelContext.insert(filter)
		
		dismiss = false
		settingsStore.triggerHaptic(&hapticSaved)
		ReviewStore.requestReview()
	}
}


#Preview {
	GearCatalogAddFilterView(
		dismiss: .constant(false)
	)
	.modelContainer(
		for: OwnedFilter.self,
		inMemory: true
	)
}
