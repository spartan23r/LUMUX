//
//  OnboardingScreen.swift
//  LUXUM
//
//  Created for Luxum.
//

import SwiftUI

struct OnboardingScreen: View {
	
	// MARK: - properties
	
	@Environment(SettingsStore.self) private var settingsStore
	
	@State private var page: Page = .welcome
	
	let onAddGear: (() -> Void)?
	
	// MARK: - init
	
	init(
		onAddGear: (() -> Void)? = nil
	) {
		self.onAddGear = onAddGear
	}
	
	
	// MARK: - body
	
	var body: some View {
		VStack(spacing: 0) {
			TabView(selection: $page) {
				welcomePage
					.tag(Page.welcome)
				
				learnPage
					.tag(Page.learn)
				
				gearPage
					.tag(Page.gear)
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
			
			footer
		}
		.background(Color(.systemGroupedBackground))
		.ignoresSafeArea(edges: .bottom)
	}
}


// MARK: - pages
private extension OnboardingScreen {
	
	@ViewBuilder
	func luxumLogo(size: CGFloat) -> some View {
		Image("lumux-icon")
			.resizable()
			.scaledToFit()
			.frame(width: size, height: size)
			.accessibilityHidden(true)
	}
	
	@ViewBuilder
	var welcomePage: some View {
		OnboardingPage {
			VStack(spacing: 28) {
				luxumLogo(size: 120)
				
				VStack(spacing: 12) {
					Text("Welcome to Luxum")
						.font(.largeTitle)
						.fontWeight(.bold)
						.multilineTextAlignment(.center)
					
					Text("Photography, made clearer.")
						.font(.title3)
						.fontWeight(.semibold)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.center)
					
					Text(
						"Learn photography, discover shooting techniques, and get more from the gear you already own."
					)
					.font(.body)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
				}
			}
		}
	}
	
	@ViewBuilder
	var learnPage: some View {
		OnboardingPage {
			VStack(spacing: 28) {
				heroIcon(
					systemName: "graduationcap",
					size: 72
				)
				
				VStack(spacing: 12) {
					Text("Learn by shooting")
						.font(.largeTitle)
						.fontWeight(.bold)
						.multilineTextAlignment(.center)
					
					Text(
						"Explore photography recipes for real-world situations and understand the techniques behind every shot."
					)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
				}
				
				VStack(spacing: 0) {
					exampleRow(
						systemName: "water.waves",
						title: "Waterfalls",
						subtitle: "Create smooth, flowing water"
					)
					
					Divider()
					
					exampleRow(
						systemName: "sun.max",
						title: "Backlit Portrait",
						subtitle: "Control bright light behind your subject"
					)
					
					Divider()
					
					exampleRow(
						systemName: "camera.aperture",
						title: "Aperture",
						subtitle: "Control light and depth of field"
					)
				}
				.padding(.horizontal, 20)
				.background(
					RoundedRectangle(
						cornerRadius: 28,
						style: .continuous
					)
					.fill(Color(.secondarySystemGroupedBackground))
				)
			}
		}
	}
	
	@ViewBuilder
	var gearPage: some View {
		OnboardingPage {
			VStack(spacing: 28) {
				heroIcon(
					systemName: "backpack",
					size: 72
				)
				
				VStack(spacing: 12) {
					Text("Built around your gear")
						.font(.largeTitle)
						.fontWeight(.bold)
						.multilineTextAlignment(.center)
					
					Text(
						"Add your cameras and lenses so Luxum can show you techniques and recipes that match your setup."
					)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
				}
				
				VStack(spacing: 0) {
					gearRow(
						systemName: "camera",
						title: "Sony A6700",
						subtitle: "APS-C"
					)
					
					Divider()
					
					gearRow(
						systemName: "camera.aperture",
						title: "E 16-55mm F2.8 G",
						subtitle: "Sony E"
					)
				}
				.padding(.horizontal, 20)
				.background(
					RoundedRectangle(
						cornerRadius: 28,
						style: .continuous
					)
					.fill(Color(.secondarySystemGroupedBackground))
				)
				
				HStack {
					Image(systemName: "checkmark")
						.symbolVariant(.circle.fill)
						.foregroundStyle(.white, .blue)
					Text("Matches your gear")
						.foregroundStyle(.tint)
				}
				.font(.headline)
				
			}
		}
	}
}


// MARK: - footer
private extension OnboardingScreen {
	
	@ViewBuilder
	var footer: some View {
		VStack(spacing: 14) {
			pageIndicator
			
			if page == .gear {
				Button {
					withAnimation {
						settingsStore.finishOnboarding()
					}
					onAddGear?()
				} label: {
					Text("Add My Gear")
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.controlSize(.large)
				
				Button("Skip for Now") {
					withAnimation {
						settingsStore.finishOnboarding()
					}
				}
				.foregroundStyle(.secondary)
				
				Text("No account required. Your gear stays on your device.")
					.font(.caption)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.center)
			} else {
				Button {
					withAnimation {
						page = page.next
					}
				} label: {
					Text("Continue")
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.controlSize(.large)
			}
		}
		.padding(.horizontal, 24)
		.padding(.top, 12)
		.padding(.bottom, 26)
		.background(.ultraThinMaterial)
		.animation(.easeInOut, value: page)
	}
	
	@ViewBuilder
	var pageIndicator: some View {
		HStack(spacing: 8) {
			ForEach(Page.allCases, id: \.self) { item in
				Capsule()
					.fill(
						item == page
							? Color.accentColor
							: Color.secondary.opacity(0.25)
					)
					.frame(
						width: item == page ? 24 : 8,
						height: 8
					)
					.animation(
						.easeInOut(duration: 0.2),
						value: page
					)
			}
		}
	}
}


// MARK: - components
private extension OnboardingScreen {
	
	func heroIcon(
		systemName: String,
		size: CGFloat
	) -> some View {
		Image(systemName: systemName)
			.font(
				.system(
					size: size,
					weight: .regular
				)
			)
			.foregroundStyle(.tint)
			.frame(
				width: 148,
				height: 148
			)
			.background(
				Circle()
					.fill(
						Color.accentColor.opacity(0.10)
					)
			)
	}
	
	func exampleRow(
		systemName: String,
		title: String,
		subtitle: String
	) -> some View {
		HStack(spacing: 14) {
			Image(systemName: systemName)
				.font(.title3)
				.foregroundStyle(.tint)
				.frame(width: 30)
			
			VStack(
				alignment: .leading,
				spacing: 3
			) {
				Text(title)
					.fontWeight(.medium)
				
				Text(subtitle)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			
			Spacer()
		}
		.padding(.vertical, 16)
	}
	
	func gearRow(
		systemName: String,
		title: String,
		subtitle: String
	) -> some View {
		HStack(spacing: 14) {
			Image(systemName: systemName)
				.font(.title3)
				.foregroundStyle(.tint)
				.frame(width: 30)
			
			VStack(
				alignment: .leading,
				spacing: 3
			) {
				Text(title)
					.fontWeight(.medium)
				
				Text(subtitle)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			
			Spacer()
		}
		.padding(.vertical, 16)
	}
}


// MARK: - page
private extension OnboardingScreen {
	
	enum Page: Int, CaseIterable {
		case welcome
		case learn
		case gear
		
		var next: Page {
			switch self {
			case .welcome:
				return .learn
				
			case .learn:
				return .gear
				
			case .gear:
				return .gear
			}
		}
	}
}


// MARK: - page container
private struct OnboardingPage<Content: View>: View {
	
	@ViewBuilder
	let content: Content
	
	var body: some View {
		ScrollView {
			content
				.frame(maxWidth: 560)
				.frame(maxWidth: .infinity)
				.padding(.horizontal, 28)
				.padding(.top, 72)
				.padding(.bottom, 32)
		}
		.scrollIndicators(.hidden)
	}
}


#Preview {
	OnboardingScreen()
		.environment(SettingsStore())
}
