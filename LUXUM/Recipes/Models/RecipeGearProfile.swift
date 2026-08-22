//
//  RecipeGearProfile.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

struct RecipeGearProfile: Codable, Hashable {
	
	let focalLengthMin: Double?
	let focalLengthMax: Double?
	
	let idealFocalLengthMin: Double?
	let idealFocalLengthMax: Double?
	
	let preferredCoverage: LensCoverage?
	let minimumMaxAperture: Double?
	let apertureImportance: Double?
	
	let requiresTripod: Bool
	let recommendsNDFilter: Bool
	let recommendsCPLFilter: Bool
	let recommendsFlash: Bool
}
