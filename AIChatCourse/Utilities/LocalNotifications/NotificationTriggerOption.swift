//
//  NotificationTriggerOption.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.02.2026.
//

import SwiftUI
import CoreLocation

public enum NotificationTriggerOption {
    case date(date: Date, repeats: Bool)
    case time(timeInterval: TimeInterval, repeats: Bool)

    @available(macCatalyst, unavailable, message: "Location-based notifications are not available on Mac Catalyst.")
    case location(coordinates: CLLocationCoordinate2D, radius: CLLocationDistance, notifyOnEntry: Bool, notifyOnExit: Bool, repeats: Bool)
}
