//
//  AppStoreRatingHelper.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.02.2026.
//

import Foundation
import SwiftUI
import StoreKit

@MainActor
final class AppStoreRatingHelper {
    
    var lastRatingsRequestReviewDate: Date = UserDefaults.lastRatingsRequest
    
    func requestRatingsReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        if #available(iOS 18.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
        
        lastRatingsRequestReviewDate = .now
    }
}

private extension UserDefaults {
    static let lastRequestedKey = "last_ratings_request_date"
    
    static var lastRatingsRequest: Date {
        get {
            standard.object(forKey: lastRequestedKey) as? Date ?? .distantPast
        }
        set {
            standard.set(newValue, forKey: lastRequestedKey)
        }
    }
}
