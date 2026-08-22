//
//  OwnedAccessory.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation
import SwiftData

@Model
final class OwnedAccessory {
	var name: String
	var brand: String?
	var kindRawValue: String
	
	var kind: AccessoryKind {
		AccessoryKind(rawValue: kindRawValue) ?? .other
	}
	
	var dateAdded: Date
	var paidPrice: Double?
	var notes: String?
	
	init(
		name: String,
		brand: String? = nil,
		kind: AccessoryKind,
		dateAdded: Date = .now,
		paidPrice: Double? = nil,
		notes: String? = nil
	) {
		self.name = name
		self.brand = brand
		self.kindRawValue = kind.rawValue
		self.dateAdded = dateAdded
		self.paidPrice = paidPrice
		self.notes = notes
	}
}
