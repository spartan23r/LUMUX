//
//  DeveloperApp.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import Foundation

struct DeveloperApp: Identifiable, Codable {
	let id: Int
	let text: String
	let subtext: String
	let link: String
	let image: String
}

extension Bundle {
	
	func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
		guard let url = self.url(forResource: file, withExtension: nil) else {
			fatalError("Failed to locate \(file) in bundle.")
		}

		guard let data = try? Data(contentsOf: url) else {
			fatalError("Failed to locate \(file) in bundle.")
		}

		let decoder = JSONDecoder()

		guard let loaded = try? decoder.decode(T.self, from: data) else {
			fatalError("Failed to decode \(file) from bundle.")
		}

		return loaded
	}
}
