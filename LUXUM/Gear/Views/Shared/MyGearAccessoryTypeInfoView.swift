//
//  MyGearAccessoryTypeInfoView.swift
//  LUXUM
//
//  Created by Ryan Rook on 22/08/2026.
//

import SwiftUI

struct MyGearAccessoryTypeInfoView: View {
	
	// MARK: - properties
	@Binding var dismiss: Bool
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			List {
				ForEach(AccessoryKind.allCases, id: \.self) { kind in
					VStack(alignment: .leading) {
						HStack(
							alignment: .center,
							spacing: 10
						) {
							Image(systemName: kind.systemImage)
								.foregroundStyle(.tint)
							
							Text(kind.title)
								.fontWeight(.medium)
						}
						
						Text(kind.subtitle)
							.font(.caption)
							.foregroundStyle(.secondary)
					}
				}
			}
			.navigationTitle("Accessory Types")
			.navigationBarTitleDisplayMode(.inline)
			.presentationDragIndicator(.visible)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						dismiss.toggle()
					}
				}
			}
		}
	}
}

#Preview {
	MyGearAccessoryTypeInfoView(dismiss: .constant(false))
}
