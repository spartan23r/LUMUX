//
//  FavoriteQuickReference.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteQuickReference {

	var topicID: String
	var createdAt: Date

	init(
		topicID: String,
		createdAt: Date = .now
	) {
		self.topicID = topicID
		self.createdAt = createdAt
	}
}
