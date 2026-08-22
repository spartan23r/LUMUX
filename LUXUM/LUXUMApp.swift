//
//  LUXUMApp.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import SwiftUI
import SwiftData

@main
struct LUXUMApp: App {
	
	// MARK: - properties
	@State private var settingsStore = SettingsStore()
	@State private var gearCatalog = GearCatalog()
	@State private var quickReferenceCatalog = QuickReferenceCatalog()
	@State private var recipeCatalog = RecipeCatalog()

	// MARK: - body
    var body: some Scene {
        WindowGroup {
			RootView()
				.environment(settingsStore)
				.environment(gearCatalog)
				.environment(quickReferenceCatalog)
				.environment(recipeCatalog)
				.preferredColorScheme(settingsStore.appearanceMode.colorScheme)
        }
		.modelContainer(SharedModelContainer.container)
    }
}
