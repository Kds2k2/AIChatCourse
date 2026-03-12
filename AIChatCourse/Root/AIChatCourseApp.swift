//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 29.12.2025.
//

import SwiftUI

@main
struct AppEntryPoint {
    static func main() {
        if AppInfo.isUnitTesting {
            TestingApp.main()
        } else {
            AIChatCourseApp.main()
        }
    }
}

struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            Group {
                if AppInfo.isUITesting {
                    AppViewForUITesting()
                } else {
                    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: delegate.dependencies.container)))
                }
            }
            .environment(delegate.dependencies.container)
            .environment(delegate.dependencies.logManager)
        }
    }
}

struct AppViewForUITesting: View {
    
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        if LaunchArgumentOptions.screenCreateAvatar.value {
            CreateAvatarView(viewModel: CreateAvatarViewModel(interactor: CoreInteractor(container: container)))
        } else {
            AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: container)))
        }
    }
}

struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Testing!")
        }
    }
}
