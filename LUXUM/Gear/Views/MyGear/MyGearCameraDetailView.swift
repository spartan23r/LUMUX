//
//  MyGearCameraDetailView.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import SwiftUI

struct MyGearCameraDetailView: View {
	
	// MARK: - properties
	@Environment(GearCatalog.self) private var gearCatalog
	var ownedItem: OwnedGearItem
	
	@State private var nickname: String
	@State private var paidPrice: String
	@State private var notes: String

	// MARK: - init
	init(ownedItem: OwnedGearItem) {
		self.ownedItem = ownedItem
		_nickname = State(initialValue: ownedItem.nickname ?? "")
		_paidPrice = State(initialValue: Self.paidPriceText(ownedItem.paidPrice))
		_notes = State(initialValue: ownedItem.notes ?? "")
	}
	
	// MARK: - body
	var body: some View {
		List {
			if let camera = ownedItem.camera(in: gearCatalog) {
				Section("General") {
					if let brand = gearCatalog.brand(for: camera.brandID) {
						LabeledContent("Brand", value: brand.name)
					}
					LabeledContent("Name", value: camera.name)
					LabeledContent("Family", value: camera.family ?? "-")
					LabeledContent("Series", value: camera.series ?? "-")
					
					if let release = camera.releaseYear {
						LabeledContent("Release Year", value: String(release))
					}
				}
				
				Section("System") {
					LabeledContent("Type", value: camera.cameraType.displayName)
					LabeledContent("Mount", value: gearCatalog.mount(for: camera.mountID ?? "")?.name ?? "—")
				}
				
				Section("Sensor") {
					LabeledContent("Sensor Format", value: camera.sensorFormat.displayName)
					LabeledContent("Crop Factor", value: cropFactorText(camera.cropFactor))
					
					if let megapixels = camera.megapixels {
						LabeledContent("Megapixels", value: formatted(megapixels))
					}
				}
				
				Section("Features") {
					
					LabeledContent("IBIS", value: camera.hasIBIS ? "Yes" : "No")
					
					if let weatherSealed = camera.weatherSealed {
						LabeledContent("Weather Sealed", value: weatherSealed ? "Yes" : "No")
					}
				}
				
				if let fixedLens = camera.fixedLens {
					Section("Fixed Lens") {
						LabeledContent(
							"Focal Length",
							value: focalLengthText(
								min: fixedLens.focalLengthMin,
								max: fixedLens.focalLengthMax
							)
						)
						
						LabeledContent(
							"Equivalent",
							value: focalLengthText(
								min: fixedLens.equivalentFocalLengthMin,
								max: fixedLens.equivalentFocalLengthMax
							)
						)
						
						LabeledContent(
							"Max Aperture",
							value: apertureText(
								wide: fixedLens.maxApertureWide,
								tele: fixedLens.maxApertureTele
							)
						)
						
						if let filterDiameter = fixedLens.filterDiameter {
							LabeledContent("Filter Diameter", value: "\(formatted(filterDiameter)) mm")
						}
					}
				}
				
				if let discontinued = camera.discontinued {
					Section {
						LabeledContent("Discontinued", value: discontinued ? "Yes" : "No")
					}
				}
				
				Section("Paid Price") {
					HStack(spacing: 4) {
						Text(Locale.current.currencySymbol ?? "")
							.foregroundStyle(.secondary)

						TextField(
							"0\(Locale.current.decimalSeparator ?? ",")00",
							text: $paidPrice
						)
						.keyboardType(.decimalPad)
					}
				}
				
				Section("Nickname") {
					TextField("Add nickname", text: $nickname)
						.textInputAutocapitalization(.words)
				}
				
				Section("Notes") {
					TextField("Add notes", text: $notes, axis: .vertical)
						.textInputAutocapitalization(.sentences)
				}
				
			}
		}
		.navigationTitle("My Gear")
		.navigationSubtitle("Camera")
		.toolbarTitleDisplayMode(.inline)
		.scrollDismissesKeyboard(.interactively)
		.onDisappear {
			saveNickname()
			savePaidPrice()
			saveNotes()
		}
	}
}

// MARK: - actions
private extension MyGearCameraDetailView {
	
	func saveNickname() {
		let trimmedNickname = nickname.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		nickname = trimmedNickname
		
		ownedItem.nickname = trimmedNickname.isEmpty
			? nil
			: trimmedNickname
	}
	
	func savePaidPrice() {
		let trimmedPrice = paidPrice.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		guard !trimmedPrice.isEmpty else {
			paidPrice = ""
			ownedItem.paidPrice = nil
			return
		}
		
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.locale = Locale.current
		
		guard let number = formatter.number(from: trimmedPrice) else {
			paidPrice = Self.paidPriceText(ownedItem.paidPrice)
			return
		}
		
		let value = number.doubleValue
		
		guard value >= 0 else {
			paidPrice = Self.paidPriceText(ownedItem.paidPrice)
			return
		}
		
		ownedItem.paidPrice = value
		paidPrice = Self.paidPriceText(value)
	}
	
	func saveNotes() {
		let trimmedNotes = notes.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		
		notes = trimmedNotes
		
		ownedItem.notes = trimmedNotes.isEmpty
			? nil
			: trimmedNotes
	}
}


// MARK: - Formatters
private extension MyGearCameraDetailView {
	
	func focalLengthText(min: Double, max: Double) -> String {
		if min == max {
			return "\(formatted(min)) mm"
		}
		
		return "\(formatted(min))–\(formatted(max)) mm"
	}
	
	func apertureText(wide: Double, tele: Double) -> String {
		if wide == tele {
			return "F\(formatted(wide))"
		}
		
		return "F\(formatted(wide))–\(formatted(tele))"
	}
	
	func formatted(_ value: Double) -> String {
		value.formatted(
			.number
				.locale(Locale(identifier: "en_US"))
				.precision(.fractionLength(0...2))
		)
	}
	
	func cropFactorText(_ value: Double) -> String {
		"\(formatted(value))x"
	}
	static func paidPriceText(_ value: Double?) -> String {
		guard let value else {
			return ""
		}
		
		return value.formatted(
			.number
				.locale(Locale.current)
				.precision(.fractionLength(0...2))
		)
	}

}

#Preview {
	MyGearCameraDetailView(ownedItem: OwnedGearItem(catalogID: "sony-a6700", kind: .camera))
}
