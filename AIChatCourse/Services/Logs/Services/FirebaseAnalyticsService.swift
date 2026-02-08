//
//  FirebaseAnalyticsService.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.02.2026.
//

import Foundation
import FirebaseAnalytics

fileprivate extension String {
    func clean(maxCharactes: Int) -> String {
        self
            .clipped(maxCharactes: maxCharactes)
            .replaceSpacesWithUnderscores()
    }
}

struct FirebaseAnalyticsService: LogService {
    
    func identifyUser(userId: String, name: String?, email: String?) {
        Analytics.setUserID(userId)
        
        if let name = name {
            Analytics.setUserProperty(name, forName: "account_name")
        }
        
        if let email = email {
            Analytics.setUserProperty(email, forName: "account_email")
        }
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        
        dict.forEach { key, value in
            if let stringValue = String.convertToStirng(value) {
                let key = key.clean(maxCharactes: 24)
                let stringValue = stringValue.clean(maxCharactes: 100)
                Analytics.setUserProperty(stringValue, forName: key)
            }
        }
    }
    
    func deleteUserProfile() {
    }
    
    func trackEvent(event: any LoggableEvent) {
        var parameters = event.parameters ?? [:]
        for (key, value) in parameters {
            if let date = value as? Date, let string = String.convertToStirng(date) {
                parameters[key] = string
            } else if let array = value as? [Any] {
                if let string = String.convertToStirng(array) {
                    parameters[key] = string
                } else {
                    parameters[key] = nil
                }
            }
        }
        
        for (key, value) in parameters where key.count > 40 {    
            parameters.removeValue(forKey: key)
            
            let newKey = key.clean(maxCharactes: 24)
            parameters[newKey] = value
        }
        
        for (key, value) in parameters {
            if let string = value as? String {
                parameters[key] = string.clean(maxCharactes: 100)
            }
        }
        
        parameters.first(upTo: 25)
        let name = event.eventName.clean(maxCharactes: 24)
        Analytics.logEvent(name, parameters: parameters.isEmpty ? nil : parameters)
    }
    
    func trackScreenEvent(event: any LoggableEvent) {
        let name = event.eventName.clean(maxCharactes: 24)
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
    }
}
