//
//  MyGearScreen.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import SwiftUI
import SwiftData

struct MyGearScreen: View {
	
	// MARK: - Properties
	@Query(
		sort: \OwnedGearItem.dateAdded,
		order: .reverse
	)
	private var ownedGear: [OwnedGearItem]
	
	@Environment(\.modelContext) private var modelContext
	
	@Environment(GearCatalog.self) private var gearCatalog
	
	@State private var isShowingAddGear = false
	
	// MARK: - Computed Properties
	private var ownedCameras: [OwnedGearItem] {
		ownedGear.filter { $0.kind == .camera }
	}
	
	private var ownedLenses: [OwnedGearItem] {
		ownedGear.filter { $0.kind == .lens }
	}
	
	// MARK: - Body
	var body: some View {
		NavigationStack {
			Group {
				if ownedGear.isEmpty {
					emptyState
				} else {
					gearList
				}
			}
			.navigationTitle("My Gear")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						isShowingAddGear = true
					} label: {
						Image(systemName: "plus")
					}
				}
			}
		}
	}
}


// MARK: - Views
private extension MyGearScreen {
	
	var emptyState: some View {
		ContentUnavailableView {
			Label("No Gear Yet", systemImage: "camera")
		} description: {
			Text("Add your cameras and lenses to build your personal gear collection.")
		} actions: {
			Button("Add Gear") {
				isShowingAddGear = true
			}
			.buttonStyle(.borderedProminent)
		}
	}
	
	var gearList: some View {
		List {
			
			if !ownedCameras.isEmpty {
				Section("Cameras") {
					ForEach(ownedCameras) { ownedItem in
						cameraRow(for: ownedItem)
					}
					.onDelete { offsets in
						deleteCameras(at: offsets)
					}
				}
			}
			
			if !ownedLenses.isEmpty {
				Section("Lenses") {
					ForEach(ownedLenses) { ownedItem in
						lensRow(for: ownedItem)
					}
					.onDelete { offsets in
						deleteLenses(at: offsets)
					}
				}
			}
			
		}
	}
}


// MARK: - Rows
private extension MyGearScreen {
	
	@ViewBuilder
	func cameraRow(for ownedItem: OwnedGearItem) -> some View {
		if let camera = ownedItem.camera(in: gearCatalog) {
			VStack(
				alignment: .leading,
				spacing: 4
			) {
				Text(ownedItem.nickname ?? camera.name)
				
				if let brand = gearCatalog.brand(
					for: camera.brandID
				) {
					Text(brand.name)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
		} else {
			unavailableGearRow
		}
	}
	
	@ViewBuilder
	func lensRow(for ownedItem: OwnedGearItem) -> some View {
		if let lens = ownedItem.lens(in: gearCatalog) {
			VStack(
				alignment: .leading,
				spacing: 4
			) {
				Text(ownedItem.nickname ?? lens.name)
				
				if let brand = gearCatalog.brand(
					for: lens.brandID
				) {
					Text(brand.name)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
		} else {
			unavailableGearRow
		}
	}
	
	var unavailableGearRow: some View {
		VStack(
			alignment: .leading,
			spacing: 4
		) {
			Text("Unknown Gear")
			
			Text(
				"This item is no longer available in the catalog."
			)
			.font(.caption)
			.foregroundStyle(.secondary)
		}
	}
}


// MARK: - Delete
private extension MyGearScreen {
	
	func deleteCameras(at offsets: IndexSet) {
		for index in offsets {
			modelContext.delete(
				ownedCameras[index]
			)
		}
	}
	
	func deleteLenses(at offsets: IndexSet) {
		for index in offsets {
			modelContext.delete(
				ownedLenses[index]
			)
		}
	}
}


#Preview {
	MyGearScreen()
		.modelContainer(for: OwnedGearItem.self, inMemory: true)
}
