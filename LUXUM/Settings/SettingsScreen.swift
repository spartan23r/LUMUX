//
//  SettingsScreen.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import SwiftUI
import SwiftData

struct SettingsScreen: View {
	
	// MARK: - properties
	@Binding var isPresented: Bool
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@Environment(\.modelContext) private var modelContext
	
	let developerAppsData = Bundle.main.decode([DeveloperApp].self, from: "AppsBySpartan23R.json")
	
	// MARK: - body
	var body: some View {
		NavigationStack {
			List {
				generalSection
				feedbackSection
				otherAppsSection
			}
			.navigationTitle("Settings")
			.toolbarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button(role: .close) {
						isPresented.toggle()
					}
				}
			}
			.presentationDetents([.medium, .large])
			.presentationDragIndicator(.visible)
		}
	}
}

#Preview {
	SettingsScreen(isPresented: .constant(false))
}

// MARK: - views
extension SettingsScreen {
	
	@ViewBuilder
	private var generalSection: some View {
		Section {
			appearanceModeView
			enableHapticsView
		} header: {
			Text("General")
		}
	}
	
	@ViewBuilder
	private var appearanceModeView: some View {
		Picker(selection: Binding(
			get: { settingsStore.appearanceMode },
			set: { settingsStore.appearanceMode = $0 }
		)) {
			ForEach(AppearanceMode.allCases) { mode in
				Text(mode.title)
					.tag(mode)
			}
		} label: {
			Label {
				Text("Appearance")
					.font(.subheadline)
			} icon: {
				Image(systemName: settingsStore.appearanceMode.iconName)
					.contentTransition(.symbolEffect(.replace))
					.listRoundedIconStyle(bgc: settingsStore.appearanceMode.iconBgcColor, filledIconStyle: true)
					.font(.subheadline)
			}
		}
	}
	
	@ViewBuilder
	private var enableHapticsView: some View {
		Toggle(isOn: Binding(
			get: { settingsStore.enableHaptics },
			set: { settingsStore.enableHaptics = $0 }
		), label: {
			Label {
				Text("Enable Haptics")
					.font(.subheadline)
			} icon: {
				Image(systemName: "iphone.radiowaves.left.and.right")
					.symbolEffect(.wiggle, value: settingsStore.enableHaptics)
					.listRoundedIconStyle(bgc: .blue, filledIconStyle: true)
					.font(.subheadline)
			}
		})
	}
	
	@ViewBuilder
	private var feedbackSection: some View {
		Section {
			rateMeView
			feedbackView
			privacyPolicyView
		} header: {
			Text("Support")
		}
	}
	
	@ViewBuilder
	private var rateMeView: some View {
		Button {
			ReviewStore.requestReviewManually()
		} label: {
			LabeledContent {
				Image(systemName: "chevron.right")
					.foregroundStyle(.accent)
			} label: {
				Label {
					Text("Rate Luxum")
						.font(.subheadline)
				} icon: {
					Image(systemName: "heart")
						.listRoundedIconStyle(bgc: .pink, filledIconStyle: true)
						.font(.subheadline)
				}
			}
		}.foregroundStyle(.primary)
	}
	
	private var feedbackURL: URL? {
		var components = URLComponents()
		components.scheme = "mailto"
		components.path = "sparky@spartan23r.com"
		components.queryItems = [
			URLQueryItem(
				name: "subject",
				value: "Luxum: Feedback"
			)
		]
		
		return components.url
	}
	
	@ViewBuilder
	private var feedbackView: some View {
		if let feedbackURL {
			Link(destination: feedbackURL) {
				LabeledContent {
					Image(systemName: "chevron.right")
						.foregroundStyle(.accent)
				} label: {
					Label {
						Text("Feedback")
							.font(.subheadline)
					} icon: {
						Image(systemName: "questionmark.bubble")
							.listRoundedIconStyle(
								bgc: .green,
								filledIconStyle: true
							)
							.font(.subheadline)
					}
				}
			}
			.foregroundStyle(.primary)
		}
	}
	
	@ViewBuilder
	private var privacyPolicyView: some View {
		Link(destination: URL(string: "https://www.spartan23r.com/AppStore/luxum-privacy-policy.pdf")!) {
			LabeledContent {
				Image(systemName: "chevron.right")
					.foregroundStyle(.accent)
			} label: {
				Label {
					Text("Privacy Policy")
						.font(.subheadline)
				} icon: {
					Image(systemName: "shield.lefthalf.filled")
						.listRoundedIconStyle(bgc: .gray, filledIconStyle: true)
						.font(.subheadline)
				}
			}
		}.foregroundStyle(.primary)
	}
	
	@ViewBuilder
	private var otherAppsSection: some View {
		Section {
			ForEach(developerAppsData) { app in
				otherAppView(app)
			}
		} header: {
			Text("My Other Apps")
		} footer: {
			appVersionNumberView
				.frame(maxWidth: .infinity, alignment: .center)
		}
	}
	
	@ViewBuilder
	private func otherAppView(_ app: DeveloperApp) -> some View {
		Link(destination: .init(string: "https://\(app.link)")!) {
			HStack(alignment: .center, spacing: 9) {
				Image(app.image)
					.resizable()
					.scaledToFit()
					.corneredRadius(radius: 12)
					.listRoundedIconStyle()
					.shadow(radius: 0.2)
				VStack(alignment: .leading) {
					Text(app.text)
						.font(.subheadline)
					Text(app.subtext)
						.font(.caption)
				}
				Spacer()
				Image(systemName: "chevron.right")
					.symbolRenderingMode(.monochrome)
					.foregroundStyle(Color.accentColor)
					.font(.callout)
			}
		}
		.tint(.primary)
	}
	
	@ViewBuilder
	private var appVersionNumberView: Text {
		Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown version")
		
	}
}
