//
//  Brand.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import Foundation

struct Brand: Codable, Identifiable, Hashable {
	let id: String
	let name: String
}

struct BrandCatalog: Codable {
	let brands: [Brand]
}
