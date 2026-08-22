//
//  MyGearScreen.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import SwiftUI
import SwiftData

struct MyGearScreen: View {
	
	// MARK: - properties
	@Query(sort: \OwnedGearItem.dateAdded, order: .reverse) private var ownedGear: [OwnedGearItem]
	@Query(sort: \OwnedFilter.dateAdded, order: .reverse) private var ownedFilters: [OwnedFilter]
	@Query(sort: \OwnedAccessory.dateAdded, order: .reverse) private var ownedAccessories: [OwnedAccessory]
	
	@Environment(\.modelContext) private var modelContext
	
	@Environment(GearCatalog.self) private var gearCatalog
	
	@State private var isShowingAddCamera = false
	@State private var isShowingAddLens = false
	@State private var isShowingAddFilter = false
	@State private var isShowingAddAccessory = false
	@State private var searchText = ""

	@AppStorage("myGear.cameraSortExpanded") private var cameraSortExpanded = true
	@AppStorage("myGear.cameraSortOption") private var cameraSortRawValue = CameraSortOption.dateAdded.rawValue
	@AppStorage("myGear.cameraSortAscending") private var cameraSortAscending = false
	
	@AppStorage("myGear.lensSortExpanded") private var lensSortExpanded = true
	@AppStorage("myGear.lensSortOption") private var lensSortRawValue = LensSortOption.dateAdded.rawValue
	@AppStorage("myGear.lensSortAscending") private var lensSortAscending = false
	
	@AppStorage("myGear.filterSortExpanded") private var filterSortExpanded = true
	@AppStorage("myGear.filterSortOption") private var filterSortRawValue = FilterSortOption.dateAdded.rawValue
	@AppStorage("myGear.filterSortAscending") private var filterSortAscending = false
	
	@AppStorage("myGear.accessorySortExpanded") private var accessorySortExpanded = true
	@AppStorage("myGear.accessorySortOption") private var accessorySortRawValue = AccessorySortOption.dateAdded.rawValue
	@AppStorage("myGear.accessorySortAscending") private var accessorySortAscending = false
	
	@Environment(SettingsStore.self) private var settingsStore
	@State private var hapticSaved = false
	
	// MARK: - computed properties
	private var ownedCameras: [OwnedGearItem] {
		ownedGear.filter { $0.kind == .camera }
	}
	
	private var ownedLenses: [OwnedGearItem] {
		ownedGear.filter { $0.kind == .lens }
	}
	
	private var hasAnyGear: Bool {
		!ownedGear.isEmpty ||
		!ownedFilters.isEmpty ||
		!ownedAccessories.isEmpty
	}

	private var hasSearchResults: Bool {
		!filteredCameras.isEmpty ||
		!filteredLenses.isEmpty ||
		!filteredFilters.isEmpty ||
		!filteredAccessories.isEmpty
	}
	
	// MARK: - body
	var body: some View {
		Group {
			if hasAnyGear {
				gearList
			} else {
				emptyState
			}
		}
		.navigationTitle("My Gear")
		.toolbarTitleDisplayMode(.inlineLarge)
		.toolbar {
			if hasAnyGear {
				ToolbarItem(placement: .topBarTrailing) {
					addGearMenuButton(inToolbar: true)
				}
			}
		}
		.sheet(isPresented: $isShowingAddCamera) {
			GearCatalogScreen(dismiss: $isShowingAddCamera, selectedGearCatalogTab: .cameras)
		}
		.sheet(isPresented: $isShowingAddLens) {
			GearCatalogScreen(dismiss: $isShowingAddLens, selectedGearCatalogTab: .lenses)
		}
		.sheet(isPresented: $isShowingAddFilter) {
			GearCatalogAddFilterView(dismiss: $isShowingAddFilter)
		}
		.sheet(isPresented: $isShowingAddAccessory) {
			GearCatalogAddAccessoryView(dismiss: $isShowingAddAccessory)
		}
		.sensoryFeedback(.success, trigger: hapticSaved)
	}
}


// MARK: - views
private extension MyGearScreen {
	
	@ViewBuilder
	func addGearMenuButton(inToolbar: Bool = false) -> some View {
		Menu {
		
			Button {
				isShowingAddCamera = true
			} label: {
				Label("Camera", systemImage: "camera")
			}
			
			Button {
				isShowingAddLens = true
			} label: {
				Label("Lens", image: "camera.aperture.circle")
			}
			
			Button {
				isShowingAddFilter = true
			} label: {
				Label("Filter", systemImage: "camera.filters")
			}
			
			Button {
				isShowingAddAccessory = true
			} label: {
				Label("Accessory", systemImage: "wrench.adjustable")
			}
			
		} label: {
			switch inToolbar {
			case true: Image(systemName: "plus")
			case false: Label("Add Gear", systemImage: "plus.circle.fill")
			}
		}
	}
	
	@ViewBuilder
	var emptyState: some View {
		ContentUnavailableView {
			Label("No Gear Yet", systemImage: "camera")
		} description: {
			Text("Add your cameras and lenses to build your personal gear collection.")
		} actions: {
			addGearMenuButton()
				.buttonStyle(.borderedProminent)
		}
	}
	
	@ViewBuilder
	var gearList: some View {
		List {
			
			if !filteredCameras.isEmpty {
				Section {
					if cameraSortExpanded {
						ForEach(sortedCameras) { ownedItem in
							cameraRow(for: ownedItem)
								.swipeActions(edge: .trailing, allowsFullSwipe: false) {
									Button(role: .destructive) {
										modelContext.delete(ownedItem)
										settingsStore.triggerHaptic(&hapticSaved)
									} label: {
										Label("Delete", systemImage: "trash")
									}
								}
						}
					}
				} header: {
					HStack {
						
						Button {
							cameraSortExpanded.toggle()
						} label: {
							HStack {
								
								Label("Cameras", systemImage: "camera")
								
								if !cameraSortExpanded {
								Spacer()
								}
								
								if !cameraSortExpanded {
									Text(sortedCameras.count, format: .number)
										.foregroundStyle(.secondary)
								}
								
								Image(systemName: "chevron.right")
									.foregroundStyle(.accent)
									.rotationEffect(.degrees(cameraSortExpanded ? 90 : 0))
								
							}
						}
						.buttonStyle(.plain)
						
						if cameraSortExpanded {
							Spacer()
							
							Menu {
								cameraSortMenu
							} label: {
								Image(systemName: "arrow.up.arrow.down")
							}
							.transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
						}
						
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			
			if !filteredLenses.isEmpty {
				Section {
					if lensSortExpanded {
						ForEach(sortedLenses) { ownedItem in
							lensRow(for: ownedItem)
								.swipeActions(edge: .trailing, allowsFullSwipe: false) {
									Button(role: .destructive) {
										modelContext.delete(ownedItem)
										settingsStore.triggerHaptic(&hapticSaved)
									} label: {
										Label("Delete", systemImage: "trash")
									}
								}
						}
					}
				} header: {
					HStack {
						
						Button {
							lensSortExpanded.toggle()
						} label: {
							HStack {
								
								Label("Lenses", image: "camera.aperture.circle")
								
								if !lensSortExpanded {
								Spacer()
								}
								
								if !lensSortExpanded {
									Text(sortedLenses.count, format: .number)
										.foregroundStyle(.secondary)
								}
								
								Image(systemName: "chevron.right")
									.foregroundStyle(.accent)
									.rotationEffect(.degrees(lensSortExpanded ? 90 : 0))
								
							}
						}
						.buttonStyle(.plain)
						
						if lensSortExpanded {
							Spacer()
							
							Menu {
								lensSortMenu
							} label: {
								Image(systemName: "arrow.up.arrow.down")
							}
							.transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
						}
						
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			
			if !filteredFilters.isEmpty {
				Section {
					if filterSortExpanded {
						ForEach(sortedFilters) { ownedItem in
							filterRow(for: ownedItem)
								.swipeActions(edge: .trailing, allowsFullSwipe: false) {
									Button(role: .destructive) {
										modelContext.delete(ownedItem)
										settingsStore.triggerHaptic(&hapticSaved)
									} label: {
										Label("Delete", systemImage: "trash")
									}
								}
						}
					}
				} header: {
					HStack {
						
						Button {
							filterSortExpanded.toggle()
						} label: {
							HStack {
								
								Label("Filters", systemImage: "camera.filters")
								
								if !filterSortExpanded {
								Spacer()
								}
								
								if !filterSortExpanded {
									Text(sortedFilters.count, format: .number)
										.foregroundStyle(.secondary)
								}
								
								Image(systemName: "chevron.right")
									.foregroundStyle(.accent)
									.rotationEffect(.degrees(filterSortExpanded ? 90 : 0))
								
							}
						}
						.buttonStyle(.plain)
						
						if filterSortExpanded {
							Spacer()
							
							Menu {
								filterSortMenu
							} label: {
								Image(systemName: "arrow.up.arrow.down")
							}
							.transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
						}
						
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			
			if !filteredAccessories.isEmpty {
				Section {
					if accessorySortExpanded {
						ForEach(sortedAccessories) { ownedItem in
							accessoryRow(for: ownedItem)
								.swipeActions(edge: .trailing, allowsFullSwipe: false) {
									Button(role: .destructive) {
										modelContext.delete(ownedItem)
										settingsStore.triggerHaptic(&hapticSaved)
									} label: {
										Label("Delete", systemImage: "trash")
									}
								}
						}
					}
				} header: {
					HStack {
						
						Button {
							accessorySortExpanded.toggle()
						} label: {
							HStack {
								
								Label("Accessories", systemImage: "wrench.adjustable")
								
								if !accessorySortExpanded {
								Spacer()
								}
								
								if !accessorySortExpanded {
									Text(sortedAccessories.count, format: .number)
										.foregroundStyle(.secondary)
								}
								
								Image(systemName: "chevron.right")
									.foregroundStyle(.accent)
									.rotationEffect(.degrees(accessorySortExpanded ? 90 : 0))
								
							}
						}
						.buttonStyle(.plain)
						
						if accessorySortExpanded {
							Spacer()
							
							Menu {
								accessorySortMenu
							} label: {
								Image(systemName: "arrow.up.arrow.down")
							}
							.transition(.asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)))
						}
						
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
			
		}
		.scrollDismissesKeyboard(.interactively)
		.animation(.snappy, value: [cameraSortExpanded, lensSortExpanded, filterSortExpanded, accessorySortExpanded])
		.searchable(
			text: $searchText,
			placement: .navigationBarDrawer(
				displayMode: .automatic
			),
			prompt: "Search gear"
		)
		.overlay {
			if
				!normalizedSearchText.isEmpty,
				!hasSearchResults
			{
				ContentUnavailableView.search(
					text: normalizedSearchText
				)
			}
		}
	}
}


// MARK: - rows
private extension MyGearScreen {
	
	@ViewBuilder
	func cameraRow(for ownedItem: OwnedGearItem) -> some View {
		if let camera = ownedItem.camera(in: gearCatalog) {
			NavigationLink {
				MyGearCameraDetailView(ownedItem: ownedItem)
			} label: {
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
					
					if let nickname = ownedItem.nickname {
						Text(nickname)
							.font(.caption)
							.foregroundStyle(.tint)
					}
					
				}
			}
		} else {
			unavailableGearRow
		}
	}
	
	@ViewBuilder
	func lensRow(for ownedItem: OwnedGearItem) -> some View {
		if let lens = ownedItem.lens(in: gearCatalog) {
			NavigationLink {
				MyGearLensDetailView(ownedItem: ownedItem)
			} label: {
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
					
					if let nickname = ownedItem.nickname {
						Text(nickname)
							.font(.caption)
							.foregroundStyle(.tint)
					}
					
				}
			}
		} else {
			unavailableGearRow
		}
	}
	
	@ViewBuilder
	func filterRow(for ownedFilter: OwnedFilter) -> some View {
		NavigationLink {
			MyGearFilterDetailView(filter: ownedFilter)
		} label: {
			VStack(alignment: .leading) {
				
				Text(ownedFilter.name)
					.fontWeight(.medium)
				
				Grid(horizontalSpacing: 6) {
					GridRow {
						
						if let brand = ownedFilter.brand {
							Text(brand)
						}
						
						if let diameter = ownedFilter.diameter {
							Text("·")
							Text("\(diameter)" + " mm")
						}
						
						if let strength = ownedFilter.strength {
							Text("·")
							Text(strength)
						} else {
							Text("·")
							Text(ownedFilter.kind.title)
						}
						
					}
				}
				.font(.caption)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.leading)
				
			}
		}
	}
	
	@ViewBuilder
	func accessoryRow(for ownedAccessory: OwnedAccessory) -> some View {
		NavigationLink {
			MyGearAccessoryDetailView(accessory: ownedAccessory)
		} label: {
			VStack(alignment: .leading) {
				
				Text(ownedAccessory.name)
					.fontWeight(.medium)
				
				Grid(horizontalSpacing: 6) {
					GridRow {
						
						if let brand = ownedAccessory.brand {
							Text(brand)
						}
						
						Text("·")
						Text(ownedAccessory.kind.title)
						
					}
				}
				.font(.caption)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.leading)
				
			}
		}
	}
	
	@ViewBuilder
	var unavailableGearRow: some View {
		VStack(alignment: .leading) {
			Text("Unknown Gear")
			
			Text(
				"This item is no longer available in the catalog."
			)
			.font(.caption)
			.foregroundStyle(.secondary)
		}
	}
}


// MARK: - search
private extension MyGearScreen {

	var normalizedSearchText: String {
		searchText.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	var filteredCameras: [OwnedGearItem] {
		guard !normalizedSearchText.isEmpty else { return ownedCameras }
		return ownedCameras.filter { gearItemMatchesSearch($0) }
	}

	var filteredLenses: [OwnedGearItem] {
		guard !normalizedSearchText.isEmpty else { return ownedLenses }
		return ownedLenses.filter { gearItemMatchesSearch($0) }
	}

	var filteredFilters: [OwnedFilter] {
		guard !normalizedSearchText.isEmpty else { return ownedFilters }
		let query = normalizedSearchText

		return ownedFilters.filter { filter in
			filter.name.localizedCaseInsensitiveContains(query) ||
			(filter.brand?.localizedCaseInsensitiveContains(query) ?? false) ||
			filter.kind.title.localizedCaseInsensitiveContains(query) ||
			(filter.strength?.localizedCaseInsensitiveContains(query) ?? false) ||
			(filter.diameter.map { "\($0) mm".localizedCaseInsensitiveContains(query) } ?? false)
		}
	}

	var filteredAccessories: [OwnedAccessory] {
		guard !normalizedSearchText.isEmpty else { return ownedAccessories }
		let query = normalizedSearchText

		return ownedAccessories.filter { accessory in
			accessory.name.localizedCaseInsensitiveContains(query) ||
			(accessory.brand?.localizedCaseInsensitiveContains(query) ?? false) ||
			accessory.kind.title.localizedCaseInsensitiveContains(query)
		}
	}

	func gearItemMatchesSearch(_ ownedItem: OwnedGearItem) -> Bool {
		let query = normalizedSearchText

		if ownedItem.nickname?.localizedCaseInsensitiveContains(query) == true {
			return true
		}

		if let camera = ownedItem.camera(in: gearCatalog) {
			return camera.name.localizedCaseInsensitiveContains(query) ||
			(gearCatalog.brand(for: camera.brandID)?.name.localizedCaseInsensitiveContains(query) ?? false) ||
			camera.sensorFormat.displayName.localizedCaseInsensitiveContains(query) ||
			(camera.megapixels.map {
				"\(formatted($0)) MP"
					.localizedCaseInsensitiveContains(query)
			} ?? false)
		}

		if let lens = ownedItem.lens(in: gearCatalog) {
			return lens.name.localizedCaseInsensitiveContains(query) ||
			(gearCatalog.brand(for: lens.brandID)?.name.localizedCaseInsensitiveContains(query) ?? false) ||
			focalLengthText(min: lens.focalLengthMin, max: lens.focalLengthMax).localizedCaseInsensitiveContains(query) ||
			apertureText(wide: lens.maxApertureWide, tele: lens.maxApertureTele).localizedCaseInsensitiveContains(query)
		}

		return false
	}
}


// MARK: - sorting
private extension MyGearScreen {

    var cameraSortOption: CameraSortOption {
        CameraSortOption(rawValue: cameraSortRawValue) ?? .dateAdded
    }

    var lensSortOption: LensSortOption {
        LensSortOption(rawValue: lensSortRawValue) ?? .dateAdded
    }

    var filterSortOption: FilterSortOption {
        FilterSortOption(rawValue: filterSortRawValue) ?? .dateAdded
    }

    var accessorySortOption: AccessorySortOption {
        AccessorySortOption(rawValue: accessorySortRawValue) ?? .dateAdded
    }

    var sortedCameras: [OwnedGearItem] {
        filteredCameras.sorted { lhs, rhs in
            let result: ComparisonResult

            switch cameraSortOption {
            case .dateAdded:
                result = lhs.dateAdded.compare(rhs.dateAdded)
            case .name:
                result = compare(
                    lhs.camera(in: gearCatalog)?.name ?? "",
                    rhs.camera(in: gearCatalog)?.name ?? ""
                )
            case .brand:
                result = compare(
                    cameraBrandName(for: lhs),
                    cameraBrandName(for: rhs)
                )
            case .sensorFormat:
                result = compare(
                    lhs.camera(in: gearCatalog)?.sensorFormat.displayName ?? "",
                    rhs.camera(in: gearCatalog)?.sensorFormat.displayName ?? ""
                )
            case .resolution:
                result = compareOptionalNumbers(
                    lhs.camera(in: gearCatalog)?.megapixels,
                    rhs.camera(in: gearCatalog)?.megapixels
                )
            }

            return ordered(result, ascending: cameraSortAscending)
        }
    }

    var sortedLenses: [OwnedGearItem] {
        filteredLenses.sorted { lhs, rhs in
            let result: ComparisonResult

            switch lensSortOption {
            case .dateAdded:
                result = lhs.dateAdded.compare(rhs.dateAdded)
            case .name:
                result = compare(
                    lhs.lens(in: gearCatalog)?.name ?? "",
                    rhs.lens(in: gearCatalog)?.name ?? ""
                )
            case .brand:
                result = compare(
                    lensBrandName(for: lhs),
                    lensBrandName(for: rhs)
                )
            case .mount:
                result = compare(
                    lensMountName(for: lhs),
                    lensMountName(for: rhs)
                )
            case .focalLength:
                result = compareLensFocalLength(lhs, rhs)
            case .aperture:
                result = compareLensAperture(lhs, rhs)
            }

            return ordered(result, ascending: lensSortAscending)
        }
    }

    var sortedFilters: [OwnedFilter] {
        filteredFilters.sorted { lhs, rhs in
            let result: ComparisonResult

            switch filterSortOption {
            case .dateAdded:
                result = lhs.dateAdded.compare(rhs.dateAdded)
            case .name:
                result = compare(lhs.name, rhs.name)
            case .brand:
                result = compare(lhs.brand ?? "", rhs.brand ?? "")
            case .type:
                result = compare(lhs.kind.title, rhs.kind.title)
            case .diameter:
                result = compareOptionalNumbers(
                    lhs.diameter.map(Double.init),
                    rhs.diameter.map(Double.init)
                )
            }

            return ordered(result, ascending: filterSortAscending)
        }
    }

    var sortedAccessories: [OwnedAccessory] {
        filteredAccessories.sorted { lhs, rhs in
            let result: ComparisonResult

            switch accessorySortOption {
            case .dateAdded:
                result = lhs.dateAdded.compare(rhs.dateAdded)
            case .name:
                result = compare(lhs.name, rhs.name)
            case .brand:
                result = compare(lhs.brand ?? "", rhs.brand ?? "")
            case .type:
                result = compare(lhs.kind.title, rhs.kind.title)
            }

            return ordered(result, ascending: accessorySortAscending)
        }
    }

    @ViewBuilder
    var cameraSortMenu: some View {
        ForEach(CameraSortOption.allCases) { option in
            Button {
                if cameraSortOption == option {
                    cameraSortAscending.toggle()
                } else {
                    cameraSortRawValue = option.rawValue
                    cameraSortAscending = defaultAscending(for: option)
                }
            } label: {
                if cameraSortOption == option {
                    Label(option.title, systemImage: cameraSortAscending ? "arrow.up" : "arrow.down")
                } else {
                    Text(option.title)
                }
            }
        }
    }

    @ViewBuilder
    var lensSortMenu: some View {
        ForEach(LensSortOption.allCases) { option in
            Button {
                if lensSortOption == option {
                    lensSortAscending.toggle()
                } else {
                    lensSortRawValue = option.rawValue
                    lensSortAscending = defaultAscending(for: option)
                }
            } label: {
                if lensSortOption == option {
                    Label(option.title, systemImage: lensSortAscending ? "arrow.up" : "arrow.down")
                } else {
                    Text(option.title)
                }
            }
        }
    }

    @ViewBuilder
    var filterSortMenu: some View {
        ForEach(FilterSortOption.allCases) { option in
            Button {
                if filterSortOption == option {
                    filterSortAscending.toggle()
                } else {
                    filterSortRawValue = option.rawValue
                    filterSortAscending = defaultAscending(for: option)
                }
            } label: {
                if filterSortOption == option {
                    Label(option.title, systemImage: filterSortAscending ? "arrow.up" : "arrow.down")
                } else {
                    Text(option.title)
                }
            }
        }
    }

    @ViewBuilder
    var accessorySortMenu: some View {
        ForEach(AccessorySortOption.allCases) { option in
            Button {
                if accessorySortOption == option {
                    accessorySortAscending.toggle()
                } else {
                    accessorySortRawValue = option.rawValue
                    accessorySortAscending = defaultAscending(for: option)
                }
            } label: {
                if accessorySortOption == option {
                    Label(option.title, systemImage: accessorySortAscending ? "arrow.up" : "arrow.down")
                } else {
                    Text(option.title)
                }
            }
        }
    }

    func defaultAscending(for option: CameraSortOption) -> Bool {
        option != .dateAdded
    }

    func defaultAscending(for option: LensSortOption) -> Bool {
        option != .dateAdded
    }

    func defaultAscending(for option: FilterSortOption) -> Bool {
        option != .dateAdded
    }

    func defaultAscending(for option: AccessorySortOption) -> Bool {
        option != .dateAdded
    }

    func ordered(_ result: ComparisonResult, ascending: Bool) -> Bool {
        ascending ? result == .orderedAscending : result == .orderedDescending
    }

    func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        lhs.localizedStandardCompare(rhs)
    }

    func compareOptionalNumbers(_ lhs: Double?, _ rhs: Double?) -> ComparisonResult {
        switch (lhs, rhs) {
        case let (lhs?, rhs?):
            if lhs < rhs { return .orderedAscending }
            if lhs > rhs { return .orderedDescending }
            return .orderedSame
        case (nil, nil):
            return .orderedSame
        case (nil, _?):
            return .orderedDescending
        case (_?, nil):
            return .orderedAscending
        }
    }

    func cameraBrandName(for item: OwnedGearItem) -> String {
        guard let camera = item.camera(in: gearCatalog) else { return "" }
        return gearCatalog.brand(for: camera.brandID)?.name ?? ""
    }

    func lensBrandName(for item: OwnedGearItem) -> String {
        guard let lens = item.lens(in: gearCatalog) else { return "" }
        return gearCatalog.brand(for: lens.brandID)?.name ?? ""
    }

    func lensMountName(for item: OwnedGearItem) -> String {
        guard let lens = item.lens(in: gearCatalog) else { return "" }
        return gearCatalog.mount(for: lens.mountID)?.name ?? ""
    }

    func compareLensFocalLength(_ lhs: OwnedGearItem, _ rhs: OwnedGearItem) -> ComparisonResult {
        guard let lhsLens = lhs.lens(in: gearCatalog) else { return .orderedDescending }
        guard let rhsLens = rhs.lens(in: gearCatalog) else { return .orderedAscending }

        if lhsLens.focalLengthMin < rhsLens.focalLengthMin { return .orderedAscending }
        if lhsLens.focalLengthMin > rhsLens.focalLengthMin { return .orderedDescending }
        if lhsLens.focalLengthMax < rhsLens.focalLengthMax { return .orderedAscending }
        if lhsLens.focalLengthMax > rhsLens.focalLengthMax { return .orderedDescending }
        return .orderedSame
    }

    func compareLensAperture(_ lhs: OwnedGearItem, _ rhs: OwnedGearItem) -> ComparisonResult {
        guard let lhsLens = lhs.lens(in: gearCatalog) else { return .orderedDescending }
        guard let rhsLens = rhs.lens(in: gearCatalog) else { return .orderedAscending }

        if lhsLens.maxApertureWide < rhsLens.maxApertureWide { return .orderedAscending }
        if lhsLens.maxApertureWide > rhsLens.maxApertureWide { return .orderedDescending }
        if lhsLens.maxApertureTele < rhsLens.maxApertureTele { return .orderedAscending }
        if lhsLens.maxApertureTele > rhsLens.maxApertureTele { return .orderedDescending }
        return .orderedSame
    }
}


// MARK: - delete
//private extension MyGearScreen {
//	
//	func deleteCameras(at offsets: IndexSet) {
//		for index in offsets {
//			modelContext.delete(
//				sortedCameras[index]
//			)
//		}
//		settingsStore.triggerHaptic(&hapticSaved)
//	}
//	
//	func deleteLenses(at offsets: IndexSet) {
//		for index in offsets {
//			modelContext.delete(
//				sortedLenses[index]
//			)
//		}
//		settingsStore.triggerHaptic(&hapticSaved)
//	}
//	
//	func deleteFilters(at offsets: IndexSet) {
//		for index in offsets {
//			modelContext.delete(
//				sortedFilters[index]
//			)
//		}
//		settingsStore.triggerHaptic(&hapticSaved)
//	}
//	
//	func deleteAccessoires(at offsets: IndexSet) {
//		for index in offsets {
//			modelContext.delete(
//				sortedAccessories[index]
//			)
//		}
//		settingsStore.triggerHaptic(&hapticSaved)
//	}
//}

// MARK: - formatters
extension MyGearScreen {
	
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

#Preview {
	MyGearScreen()
		.modelContainer(for: OwnedGearItem.self, inMemory: true)
		.environment(GearCatalog())
		.environment(SettingsStore())
}
