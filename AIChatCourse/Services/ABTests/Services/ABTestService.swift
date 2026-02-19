//
//  ABTestService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 19.02.2026.
//

import SwiftUI

protocol ABTestService {
    var activeTests: ActiveABTests { get }
    
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
}
