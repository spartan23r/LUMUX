//
//  FixedLensSpecification.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import Foundation

struct FixedLensSpecification: Codable, Hashable {
	let focalLengthMin: Double
	let focalLengthMax: Double

	let equivalentFocalLengthMin: Double
	let equivalentFocalLengthMax: Double

	let maxApertureWide: Double
	let maxApertureTele: Double

	let filterDiameter: Double?
}
