//
//  RootView.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import SwiftUI

enum RootTabs: String, CaseIterable, Identifiable {
	case home, myGear, recipes, quickReference
	var id: Self { self }
}

struct RootView: View {
	
	// MARK: - properties
	@Environment(SettingsStore.self) private var settingsStore
	@State private var selectedRootTab: RootTabs = .home
	
	// MARK: - body
	var body: some View {
		// removed onboarding in v1.0.2
//		switch settingsStore.finishedOnboarding {
//		case true: rootTabView
//		case false: onboardingView
//		}
		rootTabView
	}
}

extension RootView {
	
	@ViewBuilder
	private var rootTabView: some View {
		TabView(selection: $selectedRootTab) {
			
			Tab("Home", systemImage: "house", value: RootTabs.home) {
				NavigationStack {
					HomeScreen()
				}
			}
			
			Tab("My Gear", systemImage: "backpack", value: RootTabs.myGear) {
				NavigationStack {
					MyGearScreen()
				}
			}
			
			Tab("Recipes", systemImage: "camera.aperture", value: RootTabs.recipes) {
				NavigationStack {
					RecipesScreen()
				}
			}
			
			Tab("Quick Reference", systemImage: "book.pages", value: RootTabs.quickReference) {
				NavigationStack {
					QuickReferenceScreen()
				}
			}
			
		}
	}
	
	@ViewBuilder
	private var onboardingView: some View {
		OnboardingScreen() {
			selectedRootTab = .myGear
		}
	}
}

#Preview {
    RootView()
		.environment(QuickReferenceCatalog())
		.environment(RecipeCatalog())
		.environment(GearCatalog())
		.environment(SettingsStore())
}
