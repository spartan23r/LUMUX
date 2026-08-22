//
//  OwnedGearItem.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import Foundation
import SwiftData

@Model
final class OwnedGearItem {

	@Attribute(.unique)
	var catalogID: String
	
	var kind: GearKind
	var dateAdded: Date
	var nickname: String?
	var paidPrice: Double?
	var notes: String?
	
	init(
		catalogID: String,
		kind: GearKind,
		dateAdded: Date = .now,
		nickname: String? = nil,
		paidPrice: Double? = nil,
		notes: String? = nil
	) {
		self.catalogID = catalogID
		self.kind = kind
		self.dateAdded = dateAdded
		self.nickname = nickname
		self.paidPrice = paidPrice
		self.notes = notes
	}
}

extension OwnedGearItem {
	
	func camera(in catalog: GearCatalog) -> CameraCatalogItem? {
		guard kind == .camera else {
			return nil
		}
		
		return catalog.camera(for: catalogID)
	}
	
	func lens(in catalog: GearCatalog) -> LensCatalogItem? {
		guard kind == .lens else {
			return nil
		}
		
		return catalog.lens(for: catalogID)
	}
}
