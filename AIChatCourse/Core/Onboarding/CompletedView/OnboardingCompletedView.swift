//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State private var isCompletingProfileSetup: Bool = false
    @State private var showAlert: AnyAppAlert?
    var selectedColor: Color = .orange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup complete!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
            Text("We've set up your profile and you're ready to get start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            AsyncCallToActionButton(
                isLoading: isCompletingProfileSetup,
                title: "Finish",
                action: onFinishButtonPressed
            )
        })
        .padding(24)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $showAlert)
    }
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        logManager.trackEvent(event: Event.finishStart)
        
        Task {
            do {
                let hex = selectedColor.toHex()
                try await userManager.markOnboardingCompletedForCurrentUser(profileColorHex: hex)
                logManager.trackEvent(event: Event.finishSuccess(hex: hex))
                
                // dismiss screen
                isCompletingProfileSetup = false
                root.updateViewState(showTabBarView: true)
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case finishStart, finishSuccess(hex: String), finishFail(error: Error)
        
        static var screenName: String = "OnboardingCompletedView"
        
        var eventName: String {
            switch self {
            case .finishStart:      return "\(Event.screenName)_Finish_Start"
            case .finishSuccess:    return "\(Event.screenName)_Finish_Success"
            case .finishFail:       return "\(Event.screenName)_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishFail(error: let error):
                return error.eventParameters
            case .finishSuccess(hex: let hex):
                return ["hex_color": hex]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

#Preview {
    OnboardingCompletedView(selectedColor: .mint)
        .environment(UserManager(services: MockUserServices()))
        .environment(AppState())
}
