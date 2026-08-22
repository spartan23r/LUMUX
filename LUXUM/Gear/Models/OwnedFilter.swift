//
//  OwnedFilter.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation
import SwiftData

@Model
final class OwnedFilter {
	var name: String
	var brand: String?
	var kindRawValue: String
	var diameter: Int?
	var strength: String?

	var kind: FilterKind {
		FilterKind(rawValue: kindRawValue) ?? .other
	}
	
	var dateAdded: Date
	var paidPrice: Double?
	var notes: String?

	init(
		name: String,
		brand: String? = nil,
		kind: FilterKind,
		diameter: Int? = nil,
		strength: String? = nil,
		dateAdded: Date = .now,
		paidPrice: Double? = nil,
		notes: String? = nil
	) {
		self.name = name
		self.brand = brand
		self.kindRawValue = kind.rawValue
		self.diameter = diameter
		self.strength = strength
		self.dateAdded = dateAdded
		self.paidPrice = paidPrice
		self.notes = notes
	}
}
