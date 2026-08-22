//
//  QuickReferenceDetailView.swift
//  LUXUM
//
//  Created by Ryan Rook on 19/08/2026.
//

import SwiftUI
import SwiftData

struct QuickReferenceDetailView: View {

	// MARK: - properties

	let topic: QuickReferenceTopic

	@Query private var favoriteTopics: [FavoriteQuickReference]

	@Environment(\.modelContext)
	private var modelContext


	// MARK: - body

	var body: some View {
		List {
			Section {
				VStack(
					alignment: .leading,
					spacing: 8
				) {
					Label(
						topic.title,
						systemImage: topic.systemImage
					)
					.font(.title2)
					.fontWeight(.semibold)

					Text(topic.subtitle)
						.foregroundStyle(.secondary)

					Text(topic.summary)
						.padding(.top, 4)
				}
				.padding(.vertical, 8)
			}

			ForEach(topic.sections) { section in
				Section {
					ForEach(section.content) { content in
						contentView(
							for: content
						)
					}
				} header: {
					if let title = section.title {
						Text(title)
					}
				}
			}
		}
		.navigationTitle("Quick Reference")
		.navigationSubtitle(topic.title)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(
				placement: .topBarTrailing
			) {
				Button {
					toggleFavorite()
				} label: {
					Image(
						systemName: isFavorite
							? "heart.fill"
							: "heart"
					)
				}
				.tint(
					isFavorite
						? .pink
						: .primary
				)
				.accessibilityLabel(
					isFavorite
						? "Remove from favorites"
						: "Add to favorites"
				)
			}
		}
	}
}


// MARK: - content
private extension QuickReferenceDetailView {

	@ViewBuilder
	func contentView(
		for content: QuickReferenceContent
	) -> some View {

		switch content.type {

		case .text:
			if let text = content.text {
				Text(text)
			}

		case .values:
			if let values = content.values {
				ForEach(values) { value in
					valueRow(value)
				}
			}

		case .tip:
			if let text = content.text {
				Label {
					Text(text)
				} icon: {
					Image(
						systemName: "lightbulb"
					)
					.foregroundStyle(.tint)
				}
			}

		case .warning:
			if let text = content.text {
				Label {
					Text(text)
				} icon: {
					Image(
						systemName: "exclamationmark.triangle"
					)
					.foregroundStyle(.orange)
				}
			}
		}
	}

	func valueRow(
		_ value: QuickReferenceValue
	) -> some View {
		VStack(
			alignment: .leading,
			spacing: 4
		) {
			Text(value.value)
				.fontWeight(.medium)

			Text(value.description)
				.font(.caption)
				.foregroundStyle(.secondary)
		}
		.padding(.vertical, 2)
	}
}


// MARK: - favorites
private extension QuickReferenceDetailView {

	var favoriteTopic: FavoriteQuickReference? {
		favoriteTopics.first {
			$0.topicID == topic.id
		}
	}

	var isFavorite: Bool {
		favoriteTopic != nil
	}

	func toggleFavorite() {
		if let favoriteTopic {
			modelContext.delete(
				favoriteTopic
			)
		} else {
			let favorite = FavoriteQuickReference(
				topicID: topic.id
			)

			modelContext.insert(
				favorite
			)
		}

		do {
			try modelContext.save()
		} catch {
			assertionFailure(
				"Could not update favorite Quick Reference: \(error)"
			)
		}
	}
}


#Preview {
	NavigationStack {
		QuickReferenceDetailView(
			topic: QuickReferenceTopic(
				id: "shutter-speed",
				categoryID: "exposure",
				title: "Shutter Speed",
				subtitle: "Freeze or emphasize motion",
				systemImage: "timer",
				summary: "Shutter speed controls how long the sensor is exposed to light.",
				sections: []
			)
		)
	}
	.modelContainer(
		for: FavoriteQuickReference.self,
		inMemory: true
	)
}
