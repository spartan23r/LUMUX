//
//  FilterKind.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import Foundation

enum FilterKind: String, Codable, CaseIterable {
	case nd
	case variableND
	case cpl
	case uv
	case protector
	case mist
	case other
}

extension FilterKind {
	var title: String {
		switch self {
		case .nd:
			"ND Filter"
		case .variableND:
			"Variable ND"
		case .cpl:
			"CPL Filter"
		case .uv:
			"UV Filter"
		case .protector:
			"Protector"
		case .mist:
			"Mist Filter"
		case .other:
			"Other"
		}
	}
}
