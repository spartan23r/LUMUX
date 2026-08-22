//
//  GearCatalogCameraDetailView.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import SwiftUI

struct GearCatalogCameraDetailView: View {
	
	// MARK: - properties
	@Environment(GearCatalog.self) private var catalog
	let camera: CameraCatalogItem
	
	// MARK: - body
    var body: some View {
		List {
			Section("General") {
				if let brand = catalog.brand(for: camera.brandID) {
					LabeledContent("Brand", value: brand.name)
				}
				LabeledContent("Name", value: camera.name)
				LabeledContent("Family", value: camera.family ?? "-")
				LabeledContent("Series", value: camera.series ?? "-")
				
				if let release = camera.releaseYear {
					LabeledContent("Release Year", value: String(release))
				}
			}
			
			Section("System") {
				LabeledContent("Type", value: camera.cameraType.displayName)
				LabeledContent("Mount", value: catalog.mount(for: camera.mountID ?? "")?.name ?? "—")
			}
			
			Section("Sensor") {
				LabeledContent("Sensor Format", value: camera.sensorFormat.displayName)
				LabeledContent("Crop Factor", value: cropFactorText(camera.cropFactor))
				
				if let megapixels = camera.megapixels {
					LabeledContent("Megapixels", value: formatted(megapixels))
				}
			}
			
			Section("Features") {
				
				LabeledContent("IBIS", value: camera.hasIBIS ? "Yes" : "No")
				
				if let weatherSealed = camera.weatherSealed {
					LabeledContent("Weather Sealed", value: weatherSealed ? "Yes" : "No")
				}
			}
			
			if let fixedLens = camera.fixedLens {
				Section("Fixed Lens") {
					LabeledContent(
						"Focal Length",
						value: focalLengthText(
							min: fixedLens.focalLengthMin,
							max: fixedLens.focalLengthMax
						)
					)
					
					LabeledContent(
						"Equivalent",
						value: focalLengthText(
							min: fixedLens.equivalentFocalLengthMin,
							max: fixedLens.equivalentFocalLengthMax
						)
					)
					
					LabeledContent(
						"Max Aperture",
						value: apertureText(
							wide: fixedLens.maxApertureWide,
							tele: fixedLens.maxApertureTele
						)
					)
					
					if let filterDiameter = fixedLens.filterDiameter {
						LabeledContent("Filter Diameter", value: "\(formatted(filterDiameter)) mm")
					}
				}
			}
			
			if let discontinued = camera.discontinued {
				Section {
					LabeledContent("Discontinued", value: discontinued ? "Yes" : "No")
				}
			}
		}
		.navigationTitle("Camera")
		.navigationSubtitle(catalog.brand(for: camera.brandID)?.name ?? "")
		.toolbarTitleDisplayMode(.inline)
    }
}

// MARK: - Formatters
private extension GearCatalogCameraDetailView {
	
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
	
	func cropFactorText(_ value: Double) -> String {
		"\(formatted(value))x"
	}
}

#Preview {
	GearCatalogCameraDetailView(camera: GearCatalog().cameras.first!)
}
