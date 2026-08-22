//
//  QuickReferenceCatalog.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation
import Observation

@Observable
final class QuickReferenceCatalog {
	
	private(set) var categories: [QuickReferenceCategory] = []
	private(set) var topics: [QuickReferenceTopic] = []
	
	init() {
		categories = Self.load("quick-reference-categories", as: QuickReferenceCategoryCatalog.self).categories
		topics = Self.load("quick-reference-topics", as: QuickReferenceTopicCatalog.self).topics
	}
	
	private static func load<T: Decodable>(_ filename: String, as type: T.Type) -> T {
		guard let url = Bundle.main.url(
			forResource: filename,
			withExtension: "json"
		) else {
			fatalError("Could not find \(filename).json")
		}
		
		do {
			let data = try Data(contentsOf: url)
			
			return try JSONDecoder().decode(
				T.self,
				from: data
			)
		} catch {
			fatalError(
				"Could not decode \(filename).json: \(error)"
			)
		}
	}
}

extension QuickReferenceCatalog {
	
	func topic(for id: String) -> QuickReferenceTopic? {
		topics.first { $0.id == id }
	}
	
	func topics(for category: QuickReferenceCategory) -> [QuickReferenceTopic] {
		category.topicIDs.compactMap { topicID in
			topic(for: topicID)
		}
	}
}

struct QuickReferenceCategoryCatalog: Codable {
	let categories: [QuickReferenceCategory]
}

struct QuickReferenceTopicCatalog: Codable {
	let topics: [QuickReferenceTopic]
}
