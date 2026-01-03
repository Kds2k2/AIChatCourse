//
//  Date+addingTimeInterval.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import SwiftUI

extension Date {
    func addingTimeInterval(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        let days = TimeInterval(days * 24 * 60 * 60)
        let hours = TimeInterval(hours * 60 * 60)
        let minutes = TimeInterval(minutes * 60)
        return self.addingTimeInterval(days + hours + minutes)
    }
}
