//
//  AccessoryKind.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

enum AccessoryKind: String, Codable, CaseIterable {
	case tripod
	case monopod
	case remoteShutter
	case flash
	case memoryStorage
	case bagsCases
	case pouchesOrganizers
	case cameraRig
	case adaptersRings
	case power
	case cleaningCare
	case strapsCarry
	case weatherProtection
	case other
}

extension AccessoryKind {
	var title: String {
		switch self {
		case .tripod: "Tripod"
		case .monopod: "Monopod"
		case .remoteShutter: "Remote"
		case .flash: "Lighting"
		case .memoryStorage: "Memory & Storage"
		case .bagsCases: "Bags & Cases"
		case .pouchesOrganizers: "Pouches & Organizers"
		case .cameraRig: "Camera Rig"
		case .adaptersRings: "Adapters & Rings"
		case .power: "Power"
		case .cleaningCare: "Cleaning & Care"
		case .strapsCarry: "Straps & Carry"
		case .weatherProtection: "Weather & Protection"
		case .other: "Other"
		}
	}

	var subtitle: String {
		switch self {
		case .tripod:
			"Tabletop tripod, travel tripod"
		case .monopod:
			"Monopod"
		case .remoteShutter:
			"Remote shutter, intervalometer"
		case .flash:
			"LED light, flash, video light"
		case .memoryStorage:
			"SD cards, CFexpress, card readers, SSD"
		case .bagsCases:
			"Camera backpack, shoulder bag, hard case"
		case .pouchesOrganizers:
			"Lens pouch, filter case, SD card case"
		case .cameraRig:
			"Cage, baseplate, handles, mounting plates"
		case .adaptersRings:
			"Step-up/down rings, filter adapter rings"
		case .power:
			"Batteries, chargers, powerbanks"
		case .cleaningCare:
			"LensPen, blower, microfiber cloth"
		case .strapsCarry:
			"Camera strap, wrist strap, capture clip"
		case .weatherProtection:
			"Rain cover, camera gloves, protective gear"
		case .other:
			"Anything that doesn't fit another category"
		}
	}
	
	var systemImage: String {
		switch self {
		case .tripod:
			"camera.metering.center.weighted"
		case .monopod:
			"figure.walk"
		case .remoteShutter:
			"button.programmable"
		case .flash:
			"lightbulb.max"
		case .memoryStorage:
			"sdcard"
		case .bagsCases:
			"backpack"
		case .pouchesOrganizers:
			"shippingbox"
		case .cameraRig:
			"camera.fill"
		case .adaptersRings:
			"circle.circle"
		case .power:
			"battery.100percent"
		case .cleaningCare:
			"sparkles"
		case .strapsCarry:
			"link"
		case .weatherProtection:
			"umbrella"
		case .other:
			"ellipsis.circle"
		}
	}
}
