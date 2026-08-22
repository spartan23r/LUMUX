//
//  CatalogValidator.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import Foundation

struct CatalogValidationIssue: Identifiable, Hashable {
	enum Severity: String {
		case warning
		case error
	}

	let id = UUID()
	let severity: Severity
	let message: String
}

enum CatalogValidator {

	// MARK: - Public Validation

	static func validate(
		brands: [Brand],
		mounts: [Mount],
		cameras: [CameraCatalogItem],
		lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		issues += validateCameras(
			brands: brands,
			mounts: mounts,
			cameras: cameras
		)

		issues += validateLenses(
			brands: brands,
			mounts: mounts,
			lenses: lenses
		)

		return issues
	}
}

// MARK: - Group Validation

private extension CatalogValidator {

	static func validateCameras(
		brands: [Brand],
		mounts: [Mount],
		cameras: [CameraCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		issues += validateDuplicateIDs(
			items: cameras,
			id: \.id,
			itemName: "camera"
		)

		issues += validateCameraBrandReferences(
			brands: brands,
			cameras: cameras
		)

		issues += validateCameraMountReferences(
			mounts: mounts,
			cameras: cameras
		)

		issues += validateFixedLensRules(cameras)
		issues += validateCropFactors(cameras)
		issues += validateMegapixels(cameras)
		issues += validateCameraTypeRules(cameras)

		return issues
	}

	static func validateLenses(
		brands: [Brand],
		mounts: [Mount],
		lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		issues += validateDuplicateIDs(
			items: lenses,
			id: \.id,
			itemName: "lens"
		)

		issues += validateLensBrandReferences(
			brands: brands,
			lenses: lenses
		)

		issues += validateLensMountReferences(
			mounts: mounts,
			lenses: lenses
		)

		issues += validateLensFocalLengths(lenses)
		issues += validateLensApertures(lenses)
		issues += validateLensFilterDiameters(lenses)
		issues += validateLensFocusSpecs(lenses)
		issues += validateLensCoverageForMount(lenses)

		return issues
	}
}

// MARK: - Shared Validation Helpers

private extension CatalogValidator {

	static func validateDuplicateIDs<T>(
		items: [T],
		id: KeyPath<T, String>,
		itemName: String
	) -> [CatalogValidationIssue] {
		let grouped = Dictionary(
			grouping: items,
			by: { $0[keyPath: id] }
		)

		return grouped.compactMap { id, items in
			guard items.count > 1 else {
				return nil
			}

			return CatalogValidationIssue(
				severity: .error,
				message: "Duplicate \(itemName) id: \(id)"
			)
		}
	}
}

// MARK: - Camera Reference Validation

private extension CatalogValidator {

	static func validateCameraBrandReferences(
		brands: [Brand],
		cameras: [CameraCatalogItem]
	) -> [CatalogValidationIssue] {
		let validBrandIDs = Set(brands.map(\.id))

		return cameras.compactMap { camera in
			guard !validBrandIDs.contains(camera.brandID) else {
				return nil
			}

			return CatalogValidationIssue(
				severity: .error,
				message:
					"\(camera.id) references unknown brandID " +
					"'\(camera.brandID)'"
			)
		}
	}

	static func validateCameraMountReferences(
		mounts: [Mount],
		cameras: [CameraCatalogItem]
	) -> [CatalogValidationIssue] {
		let validMountIDs = Set(mounts.map(\.id))

		return cameras.compactMap { camera in
			guard let mountID = camera.mountID else {
				return nil
			}

			guard !validMountIDs.contains(mountID) else {
				return nil
			}

			return CatalogValidationIssue(
				severity: .error,
				message:
					"\(camera.id) references unknown mountID " +
					"'\(mountID)'"
			)
		}
	}
}

// MARK: - Camera Rules

private extension CatalogValidator {

	static func validateFixedLensRules(
		_ cameras: [CameraCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		for camera in cameras {

			if camera.cameraType == .compact {

				if let mountID = camera.mountID {
					issues.append(
						CatalogValidationIssue(
							severity: .error,
							message:
								"\(camera.id) is compact but has " +
								"mountID '\(mountID)'"
						)
					)
				}

				if camera.fixedLens == nil {
					issues.append(
						CatalogValidationIssue(
							severity: .warning,
							message:
								"\(camera.id) is compact but has no " +
								"fixedLens specification"
						)
					)
				}
			}

			if camera.fixedLens != nil,
			   camera.mountID != nil {

				issues.append(
					CatalogValidationIssue(
						severity: .error,
						message:
							"\(camera.id) has both mountID and fixedLens"
					)
				)
			}

			if camera.fixedLens == nil,
			   camera.mountID == nil,
			   camera.cameraType != .compact {

				issues.append(
					CatalogValidationIssue(
						severity: .warning,
						message:
							"\(camera.id) has neither mountID nor fixedLens"
					)
				)
			}
		}

		return issues
	}

	static func validateCropFactors(
		_ cameras: [CameraCatalogItem]
	) -> [CatalogValidationIssue] {
		cameras.compactMap { camera in

			guard camera.cropFactor > 0,
				  camera.cropFactor <= 10 else {

				return CatalogValidationIssue(
					severity: .error,
					message:
						"\(camera.id) has invalid cropFactor " +
						"\(camera.cropFactor)"
				)
			}

			switch camera.sensorFormat {

			case .fullFrame:
				guard abs(camera.cropFactor - 1.0) < 0.05 else {
					return CatalogValidationIssue(
						severity: .warning,
						message:
							"\(camera.id) is full-frame but " +
							"cropFactor is \(camera.cropFactor)"
					)
				}

			case .apsC:
				guard camera.cropFactor >= 1.4,
					  camera.cropFactor <= 1.7 else {

					return CatalogValidationIssue(
						severity: .warning,
						message:
							"\(camera.id) is APS-C but " +
							"cropFactor is \(camera.cropFactor)"
					)
				}

			case .apsH:
				guard camera.cropFactor >= 1.2,
					  camera.cropFactor <= 1.4 else {

					return CatalogValidationIssue(
						severity: .warning,
						message:
							"\(camera.id) is APS-H but " +
							"cropFactor is \(camera.cropFactor)"
					)
				}

			case .fourThirds:
				guard camera.cropFactor >= 1.9,
					  camera.cropFactor <= 2.3 else {

					return CatalogValidationIssue(
						severity: .warning,
						message:
							"\(camera.id) is Four Thirds but " +
							"cropFactor is \(camera.cropFactor)"
					)
				}

			case .oneInch:
				guard camera.cropFactor >= 2.5,
					  camera.cropFactor <= 3.0 else {

					return CatalogValidationIssue(
						severity: .warning,
						message:
							"\(camera.id) is 1-inch but " +
							"cropFactor is \(camera.cropFactor)"
					)
				}

			case .mediumFormat:
				guard camera.cropFactor < 1.0 else {
					return CatalogValidationIssue(
						severity: .warning,
						message:
							"\(camera.id) is medium format but " +
							"cropFactor is \(camera.cropFactor)"
					)
				}

			case .smaller:
				break
			}

			return nil
		}
	}

	static func validateMegapixels(
		_ cameras: [CameraCatalogItem]
	) -> [CatalogValidationIssue] {
		cameras.compactMap { camera in

			guard let megapixels = camera.megapixels else {
				return nil
			}

			if megapixels <= 0 {
				return CatalogValidationIssue(
					severity: .error,
					message:
						"\(camera.id) has invalid megapixels value " +
						"\(megapixels)"
				)
			}

			if megapixels >= 500 {
				return CatalogValidationIssue(
					severity: .warning,
					message:
						"\(camera.id) has suspicious megapixels value " +
						"\(megapixels)"
				)
			}

			return nil
		}
	}

	static func validateCameraTypeRules(
		_ cameras: [CameraCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		for camera in cameras {

			switch camera.cameraType {

			case .mirrorless,
				 .dslr,
				 .slt,
				 .rangefinder:

				if camera.mountID == nil {
					issues.append(
						CatalogValidationIssue(
							severity: .warning,
							message:
								"\(camera.id) is " +
								"\(camera.cameraType.rawValue) " +
								"but has no mountID"
						)
					)
				}

			case .compact:
				break
			}
		}

		return issues
	}
}

// MARK: - Lens Reference Validation

private extension CatalogValidator {

	static func validateLensBrandReferences(
		brands: [Brand],
		lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		let validBrandIDs = Set(brands.map(\.id))

		return lenses.compactMap { lens in
			guard !validBrandIDs.contains(lens.brandID) else {
				return nil
			}

			return CatalogValidationIssue(
				severity: .error,
				message:
					"\(lens.id) references unknown brandID " +
					"'\(lens.brandID)'"
			)
		}
	}

	static func validateLensMountReferences(
		mounts: [Mount],
		lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		let validMountIDs = Set(mounts.map(\.id))

		return lenses.compactMap { lens in
			guard !validMountIDs.contains(lens.mountID) else {
				return nil
			}

			return CatalogValidationIssue(
				severity: .error,
				message:
					"\(lens.id) references unknown mountID " +
					"'\(lens.mountID)'"
			)
		}
	}
}

// MARK: - Lens Optical Validation

private extension CatalogValidator {

	static func validateLensFocalLengths(
		_ lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		for lens in lenses {

			guard lens.focalLengthMin > 0,
				  lens.focalLengthMax > 0 else {

				issues.append(
					CatalogValidationIssue(
						severity: .error,
						message:
							"\(lens.id) has invalid focal length range " +
							"\(lens.focalLengthMin)-\(lens.focalLengthMax)mm"
					)
				)

				continue
			}

			if lens.focalLengthMin > lens.focalLengthMax {
				issues.append(
					CatalogValidationIssue(
						severity: .error,
						message:
							"\(lens.id) has focalLengthMin " +
							"\(lens.focalLengthMin) greater than " +
							"focalLengthMax \(lens.focalLengthMax)"
					)
				)
			}

			if lens.focalLengthMax > 2000 {
				issues.append(
					CatalogValidationIssue(
						severity: .warning,
						message:
							"\(lens.id) has suspicious focalLengthMax " +
							"\(lens.focalLengthMax)mm"
					)
				)
			}
		}

		return issues
	}

	static func validateLensApertures(
		_ lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		for lens in lenses {

			guard lens.maxApertureWide > 0,
				  lens.maxApertureTele > 0 else {

				issues.append(
					CatalogValidationIssue(
						severity: .error,
						message:
							"\(lens.id) has invalid aperture values " +
							"F\(lens.maxApertureWide)-" +
							"F\(lens.maxApertureTele)"
					)
				)

				continue
			}

			if lens.maxApertureWide > lens.maxApertureTele {
				issues.append(
					CatalogValidationIssue(
						severity: .error,
						message:
							"\(lens.id) has maxApertureWide " +
							"F\(lens.maxApertureWide) slower than " +
							"maxApertureTele F\(lens.maxApertureTele)"
					)
				)
			}

			if lens.maxApertureWide < 0.7 ||
				lens.maxApertureTele > 32 {

				issues.append(
					CatalogValidationIssue(
						severity: .warning,
						message:
							"\(lens.id) has suspicious aperture range " +
							"F\(lens.maxApertureWide)-" +
							"F\(lens.maxApertureTele)"
					)
				)
			}
		}

		return issues
	}

	static func validateLensFilterDiameters(
		_ lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		for lens in lenses {

			guard let filterDiameter = lens.filterDiameter else {
				continue
			}

			if filterDiameter <= 0 {
				issues.append(
					CatalogValidationIssue(
						severity: .error,
						message:
							"\(lens.id) has invalid filterDiameter " +
							"\(filterDiameter)mm"
					)
				)

				continue
			}

			if filterDiameter < 20 ||
				filterDiameter > 150 {

				issues.append(
					CatalogValidationIssue(
						severity: .warning,
						message:
							"\(lens.id) has suspicious filterDiameter " +
							"\(filterDiameter)mm"
					)
				)
			}
		}

		return issues
	}

	static func validateLensFocusSpecs(
		_ lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		var issues: [CatalogValidationIssue] = []

		for lens in lenses {

			if let minimumFocusDistance = lens.minimumFocusDistance {

				if minimumFocusDistance <= 0 {
					issues.append(
						CatalogValidationIssue(
							severity: .error,
							message:
								"\(lens.id) has invalid " +
								"minimumFocusDistance " +
								"\(minimumFocusDistance)m"
						)
					)
				} else if minimumFocusDistance > 100 {
					issues.append(
						CatalogValidationIssue(
							severity: .warning,
							message:
								"\(lens.id) has suspicious " +
								"minimumFocusDistance " +
								"\(minimumFocusDistance)m"
						)
					)
				}
			}

			if let maximumMagnification = lens.maximumMagnification {

				if maximumMagnification <= 0 {
					issues.append(
						CatalogValidationIssue(
							severity: .error,
							message:
								"\(lens.id) has invalid " +
								"maximumMagnification " +
								"\(maximumMagnification)x"
						)
					)
				} else if maximumMagnification > 10 {
					issues.append(
						CatalogValidationIssue(
							severity: .warning,
							message:
								"\(lens.id) has suspicious " +
								"maximumMagnification " +
								"\(maximumMagnification)x"
						)
					)
				}
			}
		}

		return issues
	}
}

// MARK: - Lens Mount / Coverage Validation

private extension CatalogValidator {

	static let allowedLensCoverageByMount:
		[String: Set<LensCoverage>] = [

			"sony-e": [
				.apsC,
				.fullFrame
			],

			"canon-rf": [
				.apsC,
				.fullFrame
			],

			"canon-ef": [
				.apsC,
				.fullFrame
			],

			"canon-ef-m": [
				.apsC
			],

			"nikon-z": [
				.apsC,
				.fullFrame
			],

			"nikon-f": [
				.apsC,
				.fullFrame
			],

			"fujifilm-x": [
				.apsC
			],

			"fujifilm-g": [
				.mediumFormat
			],

			"micro-four-thirds": [
				.fourThirds
			],

			"leica-l": [
				.apsC,
				.fullFrame
			],

			"leica-m": [
				.fullFrame
			],

			"pentax-k": [
				.apsC,
				.fullFrame
			],

			"pentax-645": [
				.mediumFormat
			],

			"hasselblad-x": [
				.mediumFormat
			],

			"hasselblad-h": [
				.mediumFormat
			],

			"sigma-sa": [
				.apsC,
				.apsH
			]
		]

	static func validateLensCoverageForMount(
		_ lenses: [LensCatalogItem]
	) -> [CatalogValidationIssue] {
		lenses.compactMap { lens in

			guard let allowedCoverage =
				allowedLensCoverageByMount[lens.mountID] else {
				return nil
			}

			guard !allowedCoverage.contains(lens.coverage) else {
				return nil
			}

			let expectedCoverage = allowedCoverage
				.map(\.rawValue)
				.sorted()
				.joined(separator: ", ")

			return CatalogValidationIssue(
				severity: .error,
				message:
					"\(lens.id) uses mount '\(lens.mountID)' " +
					"with invalid coverage " +
					"'\(lens.coverage.rawValue)'. " +
					"Expected: \(expectedCoverage)"
			)
		}
	}
}
