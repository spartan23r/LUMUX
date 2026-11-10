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

	@Environment(QuickReferenceCatalog.self)
	private var quickReferenceCatalog

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

			if !relatedTopics.isEmpty {
				Section {
					ForEach(relatedTopics) { relatedTopic in
						NavigationLink {
							QuickReferenceDetailView(
								topic: relatedTopic
							)
						} label: {
							VStack(alignment: .leading) {
								HStack(
									alignment: .center,
									spacing: 10
								) {
									Image(
										systemName: relatedTopic.systemImage
									)
									.foregroundStyle(.tint)

									Text(relatedTopic.title)
										.fontWeight(.medium)
								}

								Text(relatedTopic.subtitle)
									.font(.caption)
									.foregroundStyle(.secondary)
							}
						}
					}
				} header: {
					Text("Related Topics")
				}
			}
		}
		.navigationTitle("Quick Reference")
		.navigationSubtitle(topic.title)
		.scrollEdgeEffectStyle(.soft, for: .top)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(
				placement: .topBarTrailing
			) {
				Button {
					toggleFavorite()
					ReviewStore.requestReview()
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
		VStack(alignment: .leading) {
			Text(value.value)
				.fontWeight(.medium)

			Text(value.description)
				.font(.caption)
				.foregroundStyle(.secondary)
		}
	}
}


// MARK: - related topics
private extension QuickReferenceDetailView {

	var relatedTopics: [QuickReferenceTopic] {
		var seenIDs = Set<String>()

		return topic.relatedTopicIDs
			.compactMap { id in
				guard id != topic.id else {
					return nil
				}

				guard !seenIDs.contains(id) else {
					return nil
				}

				guard let relatedTopic = quickReferenceCatalog.topic(
					for: id
				) else {
					return nil
				}

				seenIDs.insert(id)
				return relatedTopic
			}
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
				relatedTopicIDs: [
					"shutter-priority",
					"image-stabilization",
					"continuous-autofocus"
				],
				sections: []
			)
		)
		.environment(
			QuickReferenceCatalog()
		)
	}
	.modelContainer(
		for: FavoriteQuickReference.self,
		inMemory: true
	)
}
