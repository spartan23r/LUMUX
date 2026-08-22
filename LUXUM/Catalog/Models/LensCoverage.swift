//
//  LensCoverage.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import Foundation

enum LensCoverage: String, Codable, Hashable {
	case fullFrame = "full-frame"
	case apsC = "aps-c"
	case apsH = "aps-h"
	case fourThirds = "four-thirds"
	case mediumFormat = "medium-format"
}

extension LensCoverage {
	var displayName: String {
		switch self {
		case .fullFrame:
			"Full Frame"
		case .apsC:
			"APS-C"
		case .apsH:
			"APS-H"
		case .fourThirds:
			"Four Thirds"
		case .mediumFormat:
			"Medium Format"
		}
	}
}
