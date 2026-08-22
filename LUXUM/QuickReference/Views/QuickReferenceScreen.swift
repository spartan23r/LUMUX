//
//  QuickReferenceScreen.swift
//  LUXUM
//
//  Created by Ryan Rook on 18/08/2026.
//

import SwiftUI
import SwiftData

struct QuickReferenceScreen: View {

	// MARK: - properties

	@Environment(QuickReferenceCatalog.self)
	private var quickReferenceCatalog

	@Query(
		sort: \FavoriteQuickReference.createdAt,
		order: .reverse
	)
	private var favoriteTopics: [FavoriteQuickReference]

	@State private var searchText = ""


	// MARK: - body

	var body: some View {
		List {
			if
				normalizedSearchText.isEmpty,
				!favoriteTopicItems.isEmpty
			{
				Section {
					ForEach(favoriteTopicItems) { topic in
						topicRow(topic)
					}
				} header: {
					Label(
						"Favorites",
						systemImage: "heart.fill"
					)
				}
			}

			ForEach(filteredCategories) { category in
				let topics = filteredTopics(
					for: category
				)

				if !topics.isEmpty {
					Section {
						ForEach(topics) { topic in
							topicRow(topic)
						}
					} header: {
						Label(
							category.name,
							systemImage: category.systemImage
						)
					}
				}
			}
		}
		.navigationTitle("Quick Reference")
		.toolbarTitleDisplayMode(.inlineLarge)
		.scrollDismissesKeyboard(.interactively)
		.searchable(
			text: $searchText,
			placement: .navigationBarDrawer(
				displayMode: .automatic
			),
			prompt: "Search quick reference"
		)
		.overlay {
			if
				!normalizedSearchText.isEmpty,
				filteredCategories.isEmpty
			{
				ContentUnavailableView.search(
					text: normalizedSearchText
				)
			}
		}
	}
}


// MARK: - views
private extension QuickReferenceScreen {

	@ViewBuilder
	func topicRow(
		_ topic: QuickReferenceTopic
	) -> some View {
		NavigationLink {
			QuickReferenceDetailView(
				topic: topic
			)
		} label: {
			VStack(alignment: .leading) {
				HStack(
					alignment: .center,
					spacing: 10
				) {
					Image(systemName: topic.systemImage)
						.foregroundStyle(.tint)

					Text(topic.title)
						.fontWeight(.medium)
				}

				Text(topic.subtitle)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}
}


// MARK: - favorites
private extension QuickReferenceScreen {

	var favoriteTopicItems: [QuickReferenceTopic] {
		favoriteTopics.compactMap { favorite in
			quickReferenceCatalog.topic(
				for: favorite.topicID
			)
		}
	}
}


// MARK: - search
private extension QuickReferenceScreen {

	var normalizedSearchText: String {
		searchText
			.trimmingCharacters(
				in: .whitespacesAndNewlines
			)
	}

	var filteredCategories: [QuickReferenceCategory] {
		guard !normalizedSearchText.isEmpty else {
			return quickReferenceCatalog.categories
		}

		return quickReferenceCatalog.categories.filter { category in
			!filteredTopics(
				for: category
			)
			.isEmpty
		}
	}

	func filteredTopics(
		for category: QuickReferenceCategory
	) -> [QuickReferenceTopic] {
		let topics = quickReferenceCatalog.topics(
			for: category
		)

		guard !normalizedSearchText.isEmpty else {
			return topics
		}

		return topics.filter { topic in
			topicMatchesSearch(
				topic,
				category: category
			)
		}
	}

	func topicMatchesSearch(
		_ topic: QuickReferenceTopic,
		category: QuickReferenceCategory
	) -> Bool {
		let query = normalizedSearchText

		if topic.title.localizedCaseInsensitiveContains(query) ||
			topic.subtitle.localizedCaseInsensitiveContains(query) ||
			topic.summary.localizedCaseInsensitiveContains(query) ||
			category.name.localizedCaseInsensitiveContains(query) {
			return true
		}

		return topic.sections.contains { section in
			sectionMatchesSearch(
				section,
				query: query
			)
		}
	}

	func sectionMatchesSearch(
		_ section: QuickReferenceSection,
		query: String
	) -> Bool {
		if
			let title = section.title,
			title.localizedCaseInsensitiveContains(query)
		{
			return true
		}

		return section.content.contains { content in
			contentMatchesSearch(
				content,
				query: query
			)
		}
	}

	func contentMatchesSearch(
		_ content: QuickReferenceContent,
		query: String
	) -> Bool {
		if
			let text = content.text,
			text.localizedCaseInsensitiveContains(query)
		{
			return true
		}

		if let values = content.values {
			return values.contains { value in
				value.value.localizedCaseInsensitiveContains(query) ||
					value.description.localizedCaseInsensitiveContains(query)
			}
		}

		return false
	}
}


#Preview {
	NavigationStack {
		QuickReferenceScreen()
	}
	.modelContainer(
		for: FavoriteQuickReference.self,
		inMemory: true
	)
	.environment(QuickReferenceCatalog())
}
