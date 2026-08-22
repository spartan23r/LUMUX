//
//  SettingsStore.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import SwiftUI
import Observation

@Observable
final class SettingsStore {
	
	// app appearance
	@ObservationIgnored
	@AppStorage("appearanceMode") private var persistedAppearanceMode = AppearanceMode.system
	
	var appearanceMode: AppearanceMode = .system {
		didSet {
			persistedAppearanceMode = appearanceMode
		}
	}
	
	// onboarding
	@ObservationIgnored
	@AppStorage("finishedOnboarding") private var persistedFinishedOnboarding = false
	
	var finishedOnboarding: Bool = false {
		didSet {
			persistedFinishedOnboarding = finishedOnboarding
		}
	}
	
	// haptics
	@ObservationIgnored
	@AppStorage("enableHaptics") private var persistedEnableHaptics: Bool = true

	var enableHaptics: Bool = true {
		didSet {
			persistedEnableHaptics = enableHaptics
		}
	}
	
	// init
	init() {
		appearanceMode = persistedAppearanceMode
		
		finishedOnboarding = persistedFinishedOnboarding
		
		enableHaptics = persistedEnableHaptics
	}
}

extension SettingsStore {
	
	func finishOnboarding() {
		withAnimation {
			finishedOnboarding = true
		}
	}
	
	func triggerHaptic(_ trigger: inout Bool) {
		if enableHaptics {
			trigger.toggle()
		}
	}
	
}

enum AppearanceMode: String, CaseIterable, Identifiable {
	case system
	case light
	case dark

	var id: Self { self }

	var title: String {
		switch self {
		case .system:
			"System"
		case .light:
			"Light"
		case .dark:
			"Dark"
		}
	}

	var iconName: String {
		switch self {
		case .system:
			"sun.righthalf.filled"
		case .light:
			"sun.max.fill"
		case .dark:
			"moon.fill"
		}
	}
	
	var iconBgcColor: Color {
		switch self {
		case .system:
				.blue
		case .light:
				.orange
		case .dark:
				.indigo
		}
	}


	var colorScheme: ColorScheme? {
		switch self {
		case .system:
			nil
		case .light:
			.light
		case .dark:
			.dark
		}
	}
}
