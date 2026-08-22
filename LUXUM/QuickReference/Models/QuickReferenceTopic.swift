//
//  QuickReferenceTopic.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

struct QuickReferenceTopic: Codable, Identifiable, Hashable {

	let id: String
	let categoryID: String

	let title: String
	let subtitle: String
	let systemImage: String

	let summary: String

	let relatedTopicIDs: [String]
	let sections: [QuickReferenceSection]
}
