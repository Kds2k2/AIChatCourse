//
//  ATT+EXT.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.02.2026.
//

import SwiftUI
import AppTrackingTransparency

final class AppTrackingTransparencyHelper {
    
    public static func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus {
        await ATTrackingManager.requestTrackingAuthorization()
    }
}

extension ATTrackingManager.AuthorizationStatus {
    
    var eventParameters: [String: Any] {
        [
            "att_status": stringValue,
            "att_status_code": rawValue
        ]
    }
    
    var stringValue: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorized:
            return "authorized"
        default:
            return "unknown"
        }
    }
}
