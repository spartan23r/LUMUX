//
//  GearCatalogScreen.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import SwiftUI
import SwiftData

struct GearCatalogScreen: View {
	
	// MARK: - Properties
	@Binding var dismiss: Bool
	
	@Environment(GearCatalog.self) private var catalog
	@Environment(\.modelContext) private var modelContext
	
	@Query private var ownedGear: [OwnedGearItem]
	
	// MARK: - Body
	var body: some View {
		NavigationStack {
			TabView {
				
				Tab {
					cameraBrandListView
				} label: {
					Label("Cameras", systemImage: "camera")
				}
				
				Tab {
					lensBrandListView
				} label: {
					Label("Lenses", image: "camera.aperture.circle")
				}
				
			}
			.navigationTitle("Gear Catalog")
			.toolbarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						dismiss.toggle()
					}
				}
			}
			.interactiveDismissDisabled()
		}
	}
}

// MARK: - Cameras
extension GearCatalogScreen {
	
	private var cameraBrands: [Brand] {
		catalog.brands.filter {
			catalog.hasCameras(for: $0.id)
		}
	}
	
	@ViewBuilder
	private var cameraBrandListView: some View {
		List(cameraBrands) { brand in
			NavigationLink(brand.name) {
				cameraListView(for: brand)
			}
		}
	}
	
	@ViewBuilder
	private func cameraListView(for brand: Brand) -> some View {
		List {
			
			let mirrorless = catalog
				.cameras(for: brand.id, type: .mirrorless)
				.sorted {
					($0.releaseYear ?? 0) > ($1.releaseYear ?? 0)
				}
			
			if !mirrorless.isEmpty {
				Section(CameraType.mirrorless.displayName) {
					camerasRows(mirrorless)
				}
			}
			
			let dslr = catalog
				.cameras(for: brand.id, type: .dslr)
				.sorted {
					($0.releaseYear ?? 0) > ($1.releaseYear ?? 0)
				}
			
			if !dslr.isEmpty {
				Section(CameraType.dslr.displayName) {
					camerasRows(dslr)
				}
			}
			
			let slt = catalog
				.cameras(for: brand.id, type: .slt)
				.sorted {
					($0.releaseYear ?? 0) > ($1.releaseYear ?? 0)
				}
			
			if !slt.isEmpty {
				Section(CameraType.slt.displayName) {
					camerasRows(slt)
				}
			}
			
			let compact = catalog
				.cameras(for: brand.id, type: .compact)
				.sorted {
					($0.releaseYear ?? 0) > ($1.releaseYear ?? 0)
				}
			
			if !compact.isEmpty {
				Section(CameraType.compact.displayName) {
					camerasRows(compact)
				}
			}
			
			let rangefinder = catalog
				.cameras(for: brand.id, type: .rangefinder)
				.sorted {
					($0.releaseYear ?? 0) > ($1.releaseYear ?? 0)
				}
			
			if !rangefinder.isEmpty {
				Section(CameraType.rangefinder.displayName) {
					camerasRows(rangefinder)
				}
			}
		}
		.navigationTitle(brand.name)
		.toolbarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	private func camerasRows(
		_ cameras: [CameraCatalogItem]
	) -> some View {
		ForEach(cameras) { camera in
			NavigationLink {
				cameraDetailView(for: camera)
			} label: {
				HStack {
					VStack(alignment: .leading) {
						
						Text(camera.name)
						
						Text(camera.sensorFormat.displayName)
							.font(.caption)
							.foregroundStyle(.secondary)
						
					}
					
					Spacer()
					if isOwned(camera.id) {
						Image(systemName: "checkmark")
							.symbolVariant(.circle.fill)
							.foregroundStyle(.tint)
					}
				}
			}
		}
	}
	
	@ViewBuilder
	private func cameraDetailView(for camera: CameraCatalogItem) -> some View {
		GearCatalogCameraDetailView(camera: camera)
			.safeAreaInset(edge: .bottom) {
				Button {
					toggleMyGear(catalogID: camera.id, kind: .camera)
				} label: {
					Label(isOwned(camera.id) ? "Remove from My Gear" : "Add to My Gear",
						  systemImage: isOwned(camera.id) ? "minus.circle.fill" : "plus.circle.fill")
				}
				.buttonStyle(.glassProminent)
				.tint(isOwned(camera.id) ? .red : .accent)
			}
	}
}

// MARK: - Lenses
extension GearCatalogScreen {
	
	private var lensBrands: [Brand] {
		catalog.brands.filter {
			catalog.hasLenses(for: $0.id)
		}
	}
	
	@ViewBuilder
	private var lensBrandListView: some View {
		List(lensBrands) { brand in
			NavigationLink(brand.name) {
				lensListView(for: brand)
			}
		}
	}
	
	@ViewBuilder
	private func lensListView(for brand: Brand) -> some View {
		let lenses = catalog
			.lenses(for: brand.id)
			.sorted {
				if $0.focalLengthMin == $1.focalLengthMin {
					return $0.focalLengthMax < $1.focalLengthMax
				}
				
				return $0.focalLengthMin < $1.focalLengthMin
			}
		
		List {
			let apsC = lenses.filter {
				$0.coverage == .apsC
			}
			
			if !apsC.isEmpty {
				Section("APS-C") {
					lensRows(apsC)
				}
			}
			
			let fullFrame = lenses.filter {
				$0.coverage == .fullFrame
			}
			
			if !fullFrame.isEmpty {
				Section("Full Frame") {
					lensRows(fullFrame)
				}
			}
			
			let apsH = lenses.filter {
				$0.coverage == .apsH
			}
			
			if !apsH.isEmpty {
				Section("APS-H") {
					lensRows(apsH)
				}
			}
			
			let fourThirds = lenses.filter {
				$0.coverage == .fourThirds
			}
			
			if !fourThirds.isEmpty {
				Section("Four Thirds") {
					lensRows(fourThirds)
				}
			}
			
			let mediumFormat = lenses.filter {
				$0.coverage == .mediumFormat
			}
			
			if !mediumFormat.isEmpty {
				Section("Medium Format") {
					lensRows(mediumFormat)
				}
			}
		}
		.navigationTitle(brand.name)
		.toolbarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	private func lensRows(
		_ lenses: [LensCatalogItem]
	) -> some View {
		ForEach(lenses) { lens in
			
//			let focalLength = focalLengthText(
//				min: lens.focalLengthMin,
//				max: lens.focalLengthMax
//			)
//
//			let aperture = apertureText(
//				wide: lens.maxApertureWide,
//				tele: lens.maxApertureTele
//			)

			NavigationLink {
				lensDetailView(for: lens)
			} label: {
//				VStack(alignment: .leading) {
//					Text(lens.name)
//					
//					Text("\(focalLength) · \(aperture)")
//						.font(.caption)
//						.foregroundStyle(.secondary)
//				}
				HStack {
					VStack(alignment: .leading) {
						
						Text(lens.name)
						
						if let mount = catalog.mount(for: lens.mountID)?.name {
							Text(mount)
								.font(.caption)
								.foregroundStyle(.secondary)
						}
						
					}
					
					Spacer()
					if isOwned(lens.id) {
						Image(systemName: "checkmark")
							.symbolVariant(.circle.fill)
							.foregroundStyle(.tint)
					}
				}
			}
		}
	}
	
	@ViewBuilder
	private func lensDetailView(for lens: LensCatalogItem) -> some View {
		GearCatalogLensDetailView(lens: lens)
			.safeAreaInset(edge: .bottom) {
				Button {
					toggleMyGear(catalogID: lens.id, kind: .lens)
				} label: {
					Label(isOwned(lens.id) ? "Remove from My Gear" : "Add to My Gear",
						  systemImage: isOwned(lens.id) ? "minus.circle.fill" : "plus.circle.fill")
				}
				.buttonStyle(.glassProminent)
				.tint(isOwned(lens.id) ? .red : .accent)
			}
	}
}

// MARK: - SwiftData
private extension GearCatalogScreen {
	
	var ownedCatalogIDs: Set<String> {
		Set(ownedGear.map(\.catalogID))
	}
	
	func isOwned(_ catalogID: String) -> Bool {
		ownedCatalogIDs.contains(catalogID)
	}
	
	func addToMyGear(
		catalogID: String,
		kind: GearKind
	) {
		guard !isOwned(catalogID) else {
			return
		}
		
		let item = OwnedGearItem(
			catalogID: catalogID,
			kind: kind
		)
		
		modelContext.insert(item)
	}
	
	func removeFromMyGear(
		catalogID: String
	) {
		guard let item = ownedGear.first(
			where: { $0.catalogID == catalogID }
		) else {
			return
		}
		
		modelContext.delete(item)
	}
	
	func toggleMyGear(
		catalogID: String,
		kind: GearKind
	) {
		if isOwned(catalogID) {
			removeFromMyGear(
				catalogID: catalogID
			)
		} else {
			addToMyGear(
				catalogID: catalogID,
				kind: kind
			)
		}
	}
}

#Preview {
	GearCatalogScreen(dismiss: .constant(false))
		.environment(GearCatalog())
		.modelContainer(for: OwnedGearItem.self, inMemory: true)
}
