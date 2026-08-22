//
//  LensCatalogItem.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import Foundation

struct LensCatalogItem: Codable, Identifiable, Hashable {
	let id: String

	// Identity
	let brandID: String
	let name: String
	let family: String?
	let series: String?
	let releaseYear: Int?

	// Compatibility
	let mountID: String
	let coverage: LensCoverage

	// Optical basics
	let focalLengthMin: Double
	let focalLengthMax: Double

	let maxApertureWide: Double
	let maxApertureTele: Double

	// Physical / useful specs
	let filterDiameter: Double?
	let hasOIS: Bool
	let weatherSealed: Bool?

	// Optional useful specs
	let minimumFocusDistance: Double?
	let maximumMagnification: Double?

	// Catalog
	let discontinued: Bool?
}

struct LensCatalog: Codable {
	let lenses: [LensCatalogItem]
}
