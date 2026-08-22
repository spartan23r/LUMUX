//
//  Mount.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import Foundation

struct Mount: Codable, Identifiable, Hashable {
	let id: String
	let name: String
	let brandIDs: [String]
}

struct MountCatalog: Codable {
	let mounts: [Mount]
}
