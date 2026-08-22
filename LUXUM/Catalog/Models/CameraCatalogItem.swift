//
//  CameraCatalogItem.swift
//  LUXUM
//
//  Created by Ryan Rook on 17/08/2026.
//

import Foundation

struct CameraCatalogItem: Codable, Identifiable, Hashable {
	let id: String

	let brandID: String
	let name: String
	let family: String?
	let series: String?
	let releaseYear: Int?

	let cameraType: CameraType
	let mountID: String?

	let sensorFormat: SensorFormat
	let cropFactor: Double

	let megapixels: Double?
	let hasIBIS: Bool
	let weatherSealed: Bool?

	let fixedLens: FixedLensSpecification?

	let discontinued: Bool?
}

struct CameraCatalog: Codable {
	let cameras: [CameraCatalogItem]
}
