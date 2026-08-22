//
//  GearCatalogAddAccessoryView.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import SwiftUI
import SwiftData

struct GearCatalogAddAccessoryView: View {
	
	// MARK: - properties
	@Binding var dismiss: Bool
	
	@Environment(\.modelContext) private var modelContext
	
	@State private var brand = ""
	@State private var name = ""
	@State private var selectedKind: AccessoryKind = .tripod
	@State private var isShowingAccessoriesTypeInfo = false
	
	@Environment(SettingsStore.self) private var settingsStore
	@State private var hapticSaved = false
	
	// MARK: - computed properties
	private var canSave: Bool {
		!name.trimmingCharacters(
			in: .whitespacesAndNewlines
		).isEmpty
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
							selection: $selectedKind
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
					
				} header: {
					Text("General")
				} footer: {
					Text("* Required")
				}
			}
			.navigationTitle("Add Accessory")
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
						addAccessory()
					}
					.disabled(!canSave)
				}
			}
			.sheet(isPresented: $isShowingAccessoriesTypeInfo) {
				MyGearAccessoryTypeInfoView(dismiss: $isShowingAccessoriesTypeInfo)
			}
			.sensoryFeedback(.success, trigger: hapticSaved)
			.interactiveDismissDisabled()
		}
	}
}


// MARK: - actions
private extension GearCatalogAddAccessoryView {
	
	func addAccessory() {
		let trimmedName = name.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		let trimmedBrand = brand.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		let accessory = OwnedAccessory(
			name: trimmedName,
			brand: trimmedBrand.isEmpty
				? nil
				: trimmedBrand,
			kind: selectedKind
		)
		
		modelContext.insert(accessory)
		
		dismiss = false
		settingsStore.triggerHaptic(&hapticSaved)
		ReviewStore.requestReview()
	}
}


#Preview {
	GearCatalogAddAccessoryView(
		dismiss: .constant(false)
	)
	.environment(SettingsStore())
	.modelContainer(
		for: OwnedAccessory.self,
		inMemory: true
	)
}
