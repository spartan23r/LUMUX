//
//  ReviewStore.swift
//  LUXUM
//
//  Created by Ryan Rook on 20/08/2026.
//

import StoreKit
import SwiftUI

class ReviewStore {
	
	static func requestReview() {
#if !targetEnvironment(simulator)
		var count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.appStartUpsCountKey)
		count += 1
		UserDefaults.standard.set(count, forKey: UserDefaultsKeys.appStartUpsCountKey)

		let infoDictionaryKey = kCFBundleVersionKey as String
		guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
		else { fatalError("Expected to find a bundle version in the info dictionary") }

		let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)

		if count >= 4 && currentVersion != lastVersionPromptedForReview {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
				if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
					SKStoreReviewController.requestReview(in: scene)
				}
			}
		}
#endif
	}

	static func requestReviewManually() {
#if !targetEnvironment(simulator)
	  let url = "https://apps.apple.com/app/id6799541928?action=write-review"
	  guard let writeReviewURL = URL(string: url)
		  else { fatalError("Expected a valid URL") }
	  UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
#endif
	}
}

struct UserDefaultsKeys {
	static let appStartUpsCountKey = "appStartUpsCountKey"
	static let lastVersionPromptedForReviewKey = "lastVersionPromptedForReviewKey"
}
