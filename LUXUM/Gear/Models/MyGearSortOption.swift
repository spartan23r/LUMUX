//
//  MyGearSortOption.swift
//  LUXUM
//
//  Created for My Gear sorting.
//

import Foundation

enum CameraSortOption: String, CaseIterable, Identifiable {
    case dateAdded
    case name
    case brand
    case sensorFormat
    case resolution

    var id: Self { self }

    var title: String {
        switch self {
        case .dateAdded: "Date Added"
        case .name: "Name"
        case .brand: "Brand"
        case .sensorFormat: "Sensor Format"
        case .resolution: "Resolution"
        }
    }
}

enum LensSortOption: String, CaseIterable, Identifiable {
    case dateAdded
    case name
    case brand
    case mount
    case focalLength
    case aperture

    var id: Self { self }

    var title: String {
        switch self {
        case .dateAdded: "Date Added"
        case .name: "Name"
        case .brand: "Brand"
        case .mount: "Mount"
        case .focalLength: "Focal Length"
        case .aperture: "Aperture"
        }
    }
}

enum FilterSortOption: String, CaseIterable, Identifiable {
    case dateAdded
    case name
    case brand
    case type
    case diameter

    var id: Self { self }

    var title: String {
        switch self {
        case .dateAdded: "Date Added"
        case .name: "Name"
        case .brand: "Brand"
        case .type: "Type"
        case .diameter: "Diameter"
        }
    }
}

enum AccessorySortOption: String, CaseIterable, Identifiable {
    case dateAdded
    case name
    case brand
    case type

    var id: Self { self }

    var title: String {
        switch self {
        case .dateAdded: "Date Added"
        case .name: "Name"
        case .brand: "Brand"
        case .type: "Type"
        }
    }
}
