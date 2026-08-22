//
//  SharedModelContainer.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import SwiftData

final class SharedModelContainer {

	static var container: ModelContainer = {

		let schema = Schema([
			OwnedGearItem.self,
			OwnedFilter.self,
			OwnedAccessory.self,
			FavoriteRecipe.self,
			FavoriteQuickReference.self
		])

		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: false
		)

		do {
			return try ModelContainer(
				for: schema,
				configurations: [
					modelConfiguration
				]
			)
		} catch {
			fatalError(
				"Could not create ModelContainer: \(error)"
			)
		}

	}()
}
