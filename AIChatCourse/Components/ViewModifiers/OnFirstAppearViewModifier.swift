//
//  OnFirstAppearViewModifier.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 11.02.2026.
//

import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !didAppear else { return }
                didAppear = true
                action()
            }
    }
}

struct OnFirstTaskViewModifier: ViewModifier {
    
    @State private var didAppear: Bool = false
    let task: () async -> Void
    
    func body(content: Content) -> some View {
        content
            .task {
                guard !didAppear else { return }
                didAppear = true
                await task()
            }
    }
}

extension View {
    func onFirstAppear(action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearViewModifier(action: action))
    }
    
    func onFirstTask(task: @escaping () async -> Void) -> some View {
        modifier(OnFirstTaskViewModifier(task: task))
    }
}
