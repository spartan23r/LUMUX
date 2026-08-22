//
//  SensorFormat.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import Foundation

enum SensorFormat: String, Codable, Hashable, CaseIterable {
	case mediumFormat = "medium-format"
	case fullFrame = "full-frame"
	case apsH = "aps-h"
	case apsC = "aps-c"
	case fourThirds = "four-thirds"
	case oneInch = "1-inch"
	case smaller
}

extension SensorFormat {
	var displayName: String {
		switch self {
		case .mediumFormat: "Medium Format"
		case .fullFrame: "Full Frame"
		case .apsH: "APS-H"
		case .apsC: "APS-C"
		case .fourThirds: "Four Thirds"
		case .oneInch: "1-inch"
		case .smaller: "Smaller Sensor"
		}
	}
}
