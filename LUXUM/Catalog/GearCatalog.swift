//
//  GearCatalog.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import Foundation
import Observation

@Observable
final class GearCatalog {
	
	private(set) var brands: [Brand] = []
	private(set) var mounts: [Mount] = []
	private(set) var cameras: [CameraCatalogItem] = []
	private(set) var lenses: [LensCatalogItem] = []

	init() {
		
		brands = Self.load("brands", as: BrandCatalog.self).brands
		mounts = Self.load("mounts", as: MountCatalog.self).mounts

		// cameras
		let sony = Self.load("sony-cameras", as: CameraCatalog.self).cameras
		let canon = Self.load("canon-cameras", as: CameraCatalog.self).cameras
		let nikon = Self.load("nikon-cameras", as: CameraCatalog.self).cameras
		let fujifilm = Self.load("fujifilm-cameras", as: CameraCatalog.self).cameras
		let panasonic = Self.load("panasonic-cameras", as: CameraCatalog.self).cameras
		let omSystem = Self.load("omsystem-cameras", as: CameraCatalog.self).cameras
		let olympus = Self.load("olympus-cameras", as: CameraCatalog.self).cameras
		let leica = Self.load("leica-cameras", as: CameraCatalog.self).cameras
		let ricoh = Self.load("ricoh-cameras", as: CameraCatalog.self).cameras
		let pentax = Self.load("pentax-cameras", as: CameraCatalog.self).cameras
		let hasselblad = Self.load("hasselblad-cameras", as: CameraCatalog.self).cameras
		let sigma = Self.load("sigma-cameras", as: CameraCatalog.self).cameras

		cameras = sony + canon + nikon + fujifilm + panasonic + omSystem + olympus + leica + ricoh + pentax + hasselblad + sigma
		
		// lenses
		let sonyLenses = Self.load("sony-lenses", as: LensCatalog.self).lenses
		let canonLenses = Self.load("canon-lenses", as: LensCatalog.self).lenses
		let nikonLenses = Self.load("nikon-lenses", as: LensCatalog.self).lenses
		let fujifilmLenses = Self.load("fujifilm-lenses", as: LensCatalog.self).lenses
		let panasonicLenses = Self.load("panasonic-lenses", as: LensCatalog.self).lenses
		let omSystemLenses = Self.load("omsystem-lenses", as: LensCatalog.self).lenses
		let olympusLenses = Self.load("olympus-lenses", as: LensCatalog.self).lenses
		let leicaLenses = Self.load("leica-lenses", as: LensCatalog.self).lenses
		let pentaxLenses = Self.load("pentax-lenses", as: LensCatalog.self).lenses
		let hasselbladLenses = Self.load("hasselblad-lenses", as: LensCatalog.self).lenses
		let sigmaLenses = Self.load("sigma-lenses", as: LensCatalog.self).lenses
		let tamronLenses = Self.load("tamron-lenses", as: LensCatalog.self).lenses
		let samyangLenses = Self.load("samyang-lenses", as: LensCatalog.self).lenses
		let tokinaLenses = Self.load("tokina-lenses", as: LensCatalog.self).lenses
		let voigtlanderLenses = Self.load("voigtlander-lenses", as: LensCatalog.self).lenses
		let laowaLenses = Self.load("laowa-lenses", as: LensCatalog.self).lenses
		let viltroxLenses = Self.load("viltrox-lenses", as: LensCatalog.self).lenses
		let zeissLenses = Self.load("zeiss-lenses", as: LensCatalog.self).lenses
		
		lenses = sonyLenses + canonLenses + nikonLenses + fujifilmLenses + panasonicLenses + omSystemLenses + olympusLenses + leicaLenses + pentaxLenses + hasselbladLenses + sigmaLenses + tamronLenses + samyangLenses + tokinaLenses + voigtlanderLenses + laowaLenses + viltroxLenses + zeissLenses
		
#if DEBUG
validateCatalog()
#endif
		
	}
	
	private static func load<T: Decodable>(_ filename: String, as type: T.Type) -> T {
		guard let url = Bundle.main.url(
			forResource: filename,
			withExtension: "json"
		) else {
			fatalError("Could not find \(filename).json")
		}
		
		do {
			let data = try Data(contentsOf: url)
			
			return try JSONDecoder().decode(
				T.self,
				from: data
			)
		} catch {
			fatalError(
				"Could not decode \(filename).json: \(error)"
			)
		}
	}
}

extension GearCatalog {
	
	func brand(for id: String) -> Brand? {
		brands.first { $0.id == id }
	}
	
	func mount(for id: String) -> Mount? {
		mounts.first { $0.id == id }
	}
	
	func mounts(for brandID: String) -> [Mount] {
		mounts.filter { $0.brandIDs.contains(brandID) }
	}
	
	func camera(for id: String) -> CameraCatalogItem? {
		cameras.first { $0.id == id }
	}
	
	func cameras(for brandID: String) -> [CameraCatalogItem] {
		cameras.filter { $0.brandID == brandID }
	}
	
	func cameras(for brandID: String, type: CameraType) -> [CameraCatalogItem] {
		cameras.filter {
			$0.brandID == brandID &&
			$0.cameraType == type
		}
	}
	
	func lens(for id: String) -> LensCatalogItem? {
		lenses.first { $0.id == id }
	}
	
	func lenses(for brandID: String) -> [LensCatalogItem] {
		lenses.filter { $0.brandID == brandID }
	}

	func hasCameras(for brandID: String) -> Bool {
		cameras.contains { $0.brandID == brandID }
	}

	func hasLenses(for brandID: String) -> Bool {
		lenses.contains { $0.brandID == brandID }
	}
}

// validation
extension GearCatalog {
	
#if DEBUG
private func validateCatalog() {
	let issues = CatalogValidator.validate(
		brands: brands,
		mounts: mounts,
		cameras: cameras,
		lenses: lenses
	)

	if issues.isEmpty {
		print("✅ Luxum catalog validation passed")
		print("   \(brands.count) brands")
		print("   \(mounts.count) mounts")
		print("   \(cameras.count) cameras")
		print("   \(lenses.count) lenses")
		return
	}

	print("⚠️ Luxum catalog validation found \(issues.count) issue(s)")

	for issue in issues {
		let icon = switch issue.severity {
		case .warning:
			"⚠️"
		case .error:
			"❌"
		}

		print("\(icon) \(issue.message)")
	}
}
#endif
	
}
