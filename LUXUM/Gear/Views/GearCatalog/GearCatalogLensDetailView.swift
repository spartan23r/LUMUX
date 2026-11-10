//
//  GearCatalogLensDetailView.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import SwiftUI

struct GearCatalogLensDetailView: View {
	
	// MARK: - properties
	@Environment(GearCatalog.self) private var catalog
	let lens: LensCatalogItem
	
	// MARK: - body
    var body: some View {
		List {
			Section("General") {
				
				if let brand = catalog.brand(for: lens.brandID) {
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
				LabeledContent("Mount", value: catalog.mount(for: lens.mountID)?.name ?? lens.mountID)
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
		}
		.navigationTitle("Lens")
		.navigationSubtitle(catalog.brand(for: lens.brandID)?.name ?? "")
		.scrollEdgeEffectStyle(.soft, for: .top)
		.toolbarTitleDisplayMode(.inline)
    }
}

// MARK: - Formatters
private extension GearCatalogLensDetailView {
	
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
}

#Preview {
	GearCatalogLensDetailView(lens: GearCatalog().lenses.first!)
}
