//
//  Error+EXT.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 08.02.2026.
//

import Foundation

extension Error {
    var eventParameters: [String: Any] {
        [
            "error_description": localizedDescription
        ]
    }
}
