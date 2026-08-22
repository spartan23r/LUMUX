//
//  CameraType.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import Foundation

enum CameraType: String, Codable, Hashable, CaseIterable {
	case mirrorless
	case dslr
	case slt
	case rangefinder
	case compact
}

extension CameraType {
	var displayName: String {
		switch self {
		case .mirrorless: "Mirrorless"
		case .dslr: "DSLR"
		case .slt: "SLT"
		case .rangefinder: "Rangefinder"
		case .compact: "Compact"
		}
	}
}
