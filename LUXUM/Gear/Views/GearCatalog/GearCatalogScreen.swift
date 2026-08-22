//
//  GearCatalogScreen.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import SwiftUI
import SwiftData

enum GearCatalogTabs: String, CaseIterable, Identifiable {
	case cameras, lenses
	var id: Self { self }
}

struct GearCatalogScreen: View {
	
	// MARK: - properties
	@Binding var dismiss: Bool
	
	@Environment(GearCatalog.self) private var gearCatalog
	@Environment(\.modelContext) private var modelContext
	
	@Query private var ownedGear: [OwnedGearItem]
	
	@State private var cameraSearchText = ""
	@State private var lensSearchText = ""
	
	@Environment(SettingsStore.self) private var settingsStore
	@State private var hapticSaved = false
	
	@State var selectedGearCatalogTab: GearCatalogTabs = .cameras
	
	// MARK: - body
	var body: some View {
		TabView(selection: $selectedGearCatalogTab) {
			
			Tab(value: GearCatalogTabs.cameras) {
				NavigationStack {
					cameraCatalogView
						.navigationTitle("Add Camera")
						.toolbarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .topBarLeading) {
								Button(role: .close) {
									dismiss.toggle()
								}
							}
						}
				}
			} label: {
				Label("Cameras", systemImage: "camera")
			}
			
			Tab(value: GearCatalogTabs.lenses) {
				NavigationStack {
					lensCatalogView
						.navigationTitle("Add Lens")
						.toolbarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .topBarLeading) {
								Button(role: .close) {
									dismiss.toggle()
								}
							}
						}
				}
			} label: {
				Label("Lenses", image: "camera.aperture.circle")
			}
		}
		.sensoryFeedback(.success, trigger: hapticSaved)
		.interactiveDismissDisabled()
	}
}

// MARK: - cameras
extension GearCatalogScreen {
	
	private var cameraBrands: [Brand] {
		gearCatalog.brands
			.filter {
				gearCatalog.hasCameras(for: $0.id)
			}
			.sorted {
				$0.name.localizedStandardCompare($1.name) == .orderedAscending
			}
	}
	
	private var normalizedCameraSearchText: String {
		cameraSearchText.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
	}
	
	private var allCameras: [CameraCatalogItem] {
		cameraBrands.flatMap { brand in
			gearCatalog.cameras(for: brand.id)
		}
	}
	
	private var filteredCameras: [CameraCatalogItem] {
		let query = normalizedCameraSearchText
		
		guard !query.isEmpty else {
			return []
		}
		
		return allCameras
			.filter { camera in
				cameraMatchesSearch(
					camera,
					query: query
				)
			}
			.sorted { lhs, rhs in
				let lhsBrand = gearCatalog.brand(for: lhs.brandID)?.name ?? ""
				let rhsBrand = gearCatalog.brand(for: rhs.brandID)?.name ?? ""
				
				if lhsBrand != rhsBrand {
					return lhsBrand.localizedStandardCompare(rhsBrand) == .orderedAscending
				}
				
				return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
			}
	}
	
	@ViewBuilder
	private var cameraCatalogView: some View {
		List {
			if normalizedCameraSearchText.isEmpty {
				
				ForEach(cameraBrands) { brand in
					NavigationLink(brand.name) {
						cameraListView(for: brand)
					}
					.fontWeight(.medium)
				}
				
			} else {
				
				ForEach(filteredCameras) { camera in
					NavigationLink {
						cameraDetailView(for: camera)
					} label: {
						HStack {
							VStack(alignment: .leading) {
								
								Text(camera.name)
									.fontWeight(.medium)
								
								Grid(horizontalSpacing: 6) {
									GridRow {
										
										if let brand = gearCatalog.brand(for: camera.brandID) {
											Text(brand.name)
										}
										
										if let sensorFormat = gearCatalog.camera(for: camera.id)?.sensorFormat {
											Text("·")
											Text(sensorFormat.displayName)
										}
										
										if let megapixels = gearCatalog.camera(for: camera.id)?.megapixels {
											Text("·")
											Text(formatted(megapixels) + " MP")
										}
									}
								}
								.font(.caption)
								.foregroundStyle(.secondary)
								.multilineTextAlignment(.leading)
								
							}
							
							Spacer()
							
							if isOwned(camera.id) {
								ownedBadge
							}
						}
					}
				}
			}
			
			feedbackView
			
		}
		.scrollDismissesKeyboard(.interactively)
		.searchable(
			text: $cameraSearchText,
			placement: .navigationBarDrawer(
				displayMode: .automatic
			),
			prompt: "Search cameras"
		)
		.overlay {
			if
				!normalizedCameraSearchText.isEmpty,
				filteredCameras.isEmpty
			{
				ContentUnavailableView.search(
					text: normalizedCameraSearchText
				)
			}
		}
	}

	@ViewBuilder
	private func cameraListView(for brand: Brand) -> some View {
		List {
			
			cameraSection(
				for: brand,
				type: .mirrorless
			)
			
			cameraSection(
				for: brand,
				type: .dslr
			)
			
			cameraSection(
				for: brand,
				type: .slt
			)
			
			cameraSection(
				for: brand,
				type: .compact
			)
			
			cameraSection(
				for: brand,
				type: .rangefinder
			)
			
			feedbackView
			
		}
		.navigationTitle("Camera")
		.navigationSubtitle(brand.name)
		.toolbarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	private func cameraSection(
		for brand: Brand,
		type: CameraType
	) -> some View {
		let cameras = gearCatalog
			.cameras(
				for: brand.id,
				type: type
			)
			.sorted {
				if ($0.releaseYear ?? 0) == ($1.releaseYear ?? 0) {
					return $0.name.localizedStandardCompare($1.name) == .orderedAscending
				}
				
				return ($0.releaseYear ?? 0) > ($1.releaseYear ?? 0)
			}
		
		if !cameras.isEmpty {
			Section(type.displayName) {
				camerasRows(cameras)
			}
		}
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
							.fontWeight(.medium)
						
						Grid(horizontalSpacing: 6) {
							GridRow {
								
								if let sensorFormat = gearCatalog.camera(for: camera.id)?.sensorFormat {
									Text(sensorFormat.displayName)
								}
								
								if let megapixels = gearCatalog.camera(for: camera.id)?.megapixels {
									Text("·")
									Text(formatted(megapixels) + " MP")
								}
							}
						}
						.font(.caption)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.leading)
						
					}
					
					Spacer()
					
					if isOwned(camera.id) {
						ownedBadge
					}
				}
			}
		}
	}
	
	private func cameraMatchesSearch(
		_ camera: CameraCatalogItem,
		query: String
	) -> Bool {
		let brand = gearCatalog.brand(for: camera.brandID)?.name ?? ""
		
		return camera.name.localizedCaseInsensitiveContains(query) ||
			brand.localizedCaseInsensitiveContains(query) ||
			camera.sensorFormat.displayName.localizedCaseInsensitiveContains(query) ||
			(camera.releaseYear.map(String.init)?.localizedCaseInsensitiveContains(query) ?? false)
	}
	
	@ViewBuilder
	private func cameraDetailView(for camera: CameraCatalogItem) -> some View {
		GearCatalogCameraDetailView(camera: camera)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						toggleMyGear(catalogID: camera.id, kind: .camera)
					} label: {
						Group {
							if isOwned(camera.id) {
								Image(systemName: "trash")
							} else {
								Text("Add")
							}
						}
						.foregroundStyle(.white)
					}
					.buttonStyle(.glassProminent)
					.tint(isOwned(camera.id) ? .red : .accent)
				}
			}
	}
}

// MARK: - lenses
extension GearCatalogScreen {
	
	private var lensBrands: [Brand] {
		gearCatalog.brands
			.filter {
				gearCatalog.hasLenses(for: $0.id)
			}
			.sorted {
				$0.name.localizedStandardCompare($1.name) == .orderedAscending
			}
	}
	
	private var normalizedLensSearchText: String {
		lensSearchText.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
	}
	
	private var allLenses: [LensCatalogItem] {
		lensBrands.flatMap { brand in
			gearCatalog.lenses(for: brand.id)
		}
	}
	
	private var filteredLenses: [LensCatalogItem] {
		let query = normalizedLensSearchText
		
		guard !query.isEmpty else {
			return []
		}
		
		return allLenses
			.filter { lens in
				lensMatchesSearch(
					lens,
					query: query
				)
			}
			.sorted { lhs, rhs in
				let lhsBrand = gearCatalog.brand(for: lhs.brandID)?.name ?? ""
				let rhsBrand = gearCatalog.brand(for: rhs.brandID)?.name ?? ""
				
				if lhsBrand != rhsBrand {
					return lhsBrand.localizedStandardCompare(rhsBrand) == .orderedAscending
				}
				
				if lhs.focalLengthMin == rhs.focalLengthMin {
					return lhs.focalLengthMax < rhs.focalLengthMax
				}
				
				return lhs.focalLengthMin < rhs.focalLengthMin
			}
	}
	
	@ViewBuilder
	private var lensCatalogView: some View {
		List {
			
			if normalizedLensSearchText.isEmpty {
				ForEach(lensBrands) { brand in
					NavigationLink(brand.name) {
						lensListView(for: brand)
					}
					.fontWeight(.medium)
				}
			} else {
				ForEach(filteredLenses) { lens in
					NavigationLink {
						lensDetailView(for: lens)
					} label: {
						HStack {
							VStack(alignment: .leading) {
								
								Text(lens.name)
									.fontWeight(.medium)
								
								Grid(horizontalSpacing: 6) {
									GridRow {
										
										if let brand = gearCatalog.brand(for: lens.brandID) {
											Text(brand.name)
										}
										
										if let mount = gearCatalog.mount(for: lens.mountID) {
											Text("·")
											Text(mount.name)
										}
										
										Text("·")
										Text(focalLengthText(min: lens.focalLengthMin, max: lens.focalLengthMax))
										
										Text("·")
										Text(apertureText(wide: lens.maxApertureWide,tele: lens.maxApertureTele))
										
									}
								}
								.font(.caption)
								.foregroundStyle(.secondary)
								.multilineTextAlignment(.leading)
								
							}
							
							Spacer()
							
							if isOwned(lens.id) {
								ownedBadge
							}
						}
					}
				}
			}
			
			feedbackView
			
		}
		.scrollDismissesKeyboard(.interactively)
		.searchable(
			text: $lensSearchText,
			placement: .navigationBarDrawer(
				displayMode: .automatic
			),
			prompt: "Search lenses"
		)
		.overlay {
			if
				!normalizedLensSearchText.isEmpty,
				filteredLenses.isEmpty
			{
				ContentUnavailableView.search(
					text: normalizedLensSearchText
				)
			}
		}
	}

	@ViewBuilder
	private func lensListView(for brand: Brand) -> some View {
		let lenses = gearCatalog
			.lenses(for: brand.id)
			.sorted(by: lensFocalLengthSort)
		
		List {
			
			lensCoverageSection(
				"APS-C",
				lenses: lenses.filter {
					$0.coverage == .apsC
				}
			)
			
			lensCoverageSection(
				"Full Frame",
				lenses: lenses.filter {
					$0.coverage == .fullFrame
				}
			)
			
			lensCoverageSection(
				"APS-H",
				lenses: lenses.filter {
					$0.coverage == .apsH
				}
			)
			
			lensCoverageSection(
				"Four Thirds",
				lenses: lenses.filter {
					$0.coverage == .fourThirds
				}
			)
			
			lensCoverageSection(
				"Medium Format",
				lenses: lenses.filter {
					$0.coverage == .mediumFormat
				}
			)
			
			feedbackView
			
		}
		.navigationTitle("Lens")
		.navigationSubtitle(brand.name)
		.toolbarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	private func lensCoverageSection(
		_ title: String,
		lenses: [LensCatalogItem]
	) -> some View {
		let zoomLenses = lenses
			.filter { !isPrime($0) }
			.sorted(by: lensFocalLengthSort)
		
		let primeLenses = lenses
			.filter(isPrime)
			.sorted(by: lensFocalLengthSort)
		
		if !lenses.isEmpty {
			Section(title) {
				if !zoomLenses.isEmpty {
					lensSubheading("Zoom Lenses")
					lensRows(zoomLenses)
				}
				
				if !primeLenses.isEmpty {
					lensSubheading("Prime Lenses")
					lensRows(primeLenses)
				}
			}
		}
	}
	
	@ViewBuilder
	private func lensSubheading(
		_ title: String
	) -> some View {
		Text(title)
			.font(.caption)
			.fontWeight(.semibold)
			.foregroundStyle(.tint)
			.textCase(.uppercase)
			.listRowSeparator(.hidden)
	}
	
	@ViewBuilder
	private func lensRows(
		_ lenses: [LensCatalogItem]
	) -> some View {
		ForEach(lenses) { lens in
			NavigationLink {
				lensDetailView(for: lens)
			} label: {
				HStack {
					VStack(alignment: .leading) {
						
						Text(lens.name)
							.fontWeight(.medium)
						
						Grid(horizontalSpacing: 6) {
							GridRow {
								
								if let mount = gearCatalog.mount(for: lens.mountID) {
									Text(mount.name)
								}
								
								Text("·")
								Text(focalLengthText(min: lens.focalLengthMin, max: lens.focalLengthMax))
								
								Text("·")
								Text(apertureText(wide: lens.maxApertureWide,tele: lens.maxApertureTele))
								
							}
						}
						.font(.caption)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.leading)
						
					}
					
					Spacer()
					
					if isOwned(lens.id) {
						ownedBadge
					}
				}
			}
		}
	}
	
	private func lensMatchesSearch(
		_ lens: LensCatalogItem,
		query: String
	) -> Bool {
		let brand = gearCatalog.brand(for: lens.brandID)?.name ?? ""
		let mount = gearCatalog.mount(for: lens.mountID)?.name ?? ""
		let focalLength = focalLengthSearchText(for: lens)
		let aperture = apertureSearchText(for: lens)
		
		return lens.name.localizedCaseInsensitiveContains(query) ||
			brand.localizedCaseInsensitiveContains(query) ||
			mount.localizedCaseInsensitiveContains(query) ||
			lensCoverageSearchText(for: lens).localizedCaseInsensitiveContains(query) ||
			focalLength.localizedCaseInsensitiveContains(query) ||
			aperture.localizedCaseInsensitiveContains(query) ||
			(isPrime(lens) ? "prime" : "zoom").localizedCaseInsensitiveContains(query)
	}
	
	private func lensCoverageSearchText(
		for lens: LensCatalogItem
	) -> String {
		switch lens.coverage {
		case .apsC:
			return "APS-C"
		case .fullFrame:
			return "Full Frame"
		case .apsH:
			return "APS-H"
		case .fourThirds:
			return "Four Thirds"
		case .mediumFormat:
			return "Medium Format"
		}
	}
	
	private func isPrime(
		_ lens: LensCatalogItem
	) -> Bool {
		lens.focalLengthMin == lens.focalLengthMax
	}
	
	private func lensFocalLengthSort(
		_ lhs: LensCatalogItem,
		_ rhs: LensCatalogItem
	) -> Bool {
		if lhs.focalLengthMin == rhs.focalLengthMin {
			if lhs.focalLengthMax == rhs.focalLengthMax {
				return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
			}
			
			return lhs.focalLengthMax < rhs.focalLengthMax
		}
		
		return lhs.focalLengthMin < rhs.focalLengthMin
	}
	
	private func focalLengthSearchText(
		for lens: LensCatalogItem
	) -> String {
		if isPrime(lens) {
			return "\(lens.focalLengthMin) mm"
		}
		
		return "\(lens.focalLengthMin)-\(lens.focalLengthMax) mm"
	}
	
	private func apertureSearchText(
		for lens: LensCatalogItem
	) -> String {
		if lens.maxApertureWide == lens.maxApertureTele {
			return "F\(lens.maxApertureWide)"
		}
		
		return "F\(lens.maxApertureWide)-\(lens.maxApertureTele)"
	}
	
	@ViewBuilder
	private func lensDetailView(for lens: LensCatalogItem) -> some View {
		GearCatalogLensDetailView(lens: lens)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						toggleMyGear(catalogID: lens.id, kind: .lens)
					} label: {
						Group {
							if isOwned(lens.id) {
								Image(systemName: "trash")
							} else {
								Text("Add")
							}
						}
						.foregroundStyle(.white)
					}
					.buttonStyle(.glassProminent)
					.tint(isOwned(lens.id) ? .red : .accent)
				}
			}
	}
}

// MARK: - shared Views
private extension GearCatalogScreen {
	
	@ViewBuilder
	var ownedBadge: some View {
		Image(systemName: "star")
			.symbolVariant(.circle.fill)
			.foregroundStyle(.white, .tint)
	}
	
	private var feedbackURL: URL? {
		var components = URLComponents()
		components.scheme = "mailto"
		components.path = "sparky@spartan23r.com"
		components.queryItems = [
			URLQueryItem(
				name: "subject",
				value: "Luxum: Can't find gear"
			)
		]
		
		return components.url
	}
	
	@ViewBuilder
	private var feedbackView: some View {
		if let feedbackURL {
			Section {
				Link(destination: feedbackURL) {
					LabeledContent {
						Image(systemName: "chevron.right")
							.foregroundStyle(.accent)
					} label: {
						VStack(alignment: .leading, spacing: 2) {
							Text("Can’t find your gear?")
								.font(.subheadline)
							
							Text("Let us know what’s missing.")
								.font(.caption)
								.foregroundStyle(.secondary)
						}
					}
				}
				.foregroundStyle(.primary)
			}
		}
	}
}

// MARK: - formatters
extension GearCatalogScreen {
	
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
		settingsStore.triggerHaptic(&hapticSaved)
		ReviewStore.requestReview()
	}
}

#Preview {
	GearCatalogScreen(dismiss: .constant(false))
		.environment(GearCatalog())
		.modelContainer(for: OwnedGearItem.self, inMemory: true)
}
