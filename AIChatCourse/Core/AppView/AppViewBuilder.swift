//
//  AppViewBuilder.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 31.12.2025.
//

import SwiftUI

struct AppViewBuilder<TabBarView: View, OnboardingView: View>: View {
    var showTabBar: Bool = false
    @ViewBuilder var tabbarView: TabBarView
    @ViewBuilder var onboardingView: OnboardingView

    var body: some View {
        ZStack {
           if showTabBar {
               tabbarView
                   .transition(.move(edge: .leading))
           } else {
               onboardingView
                   .transition(.move(edge: .trailing))
           }
        }
        .animation(.smooth, value: showTabBar)
    }
}

private struct PreviewView: View {
    @State private var showTabBar: Bool = false

    var body: some View {
        AppViewBuilder(
            showTabBar: showTabBar,
            tabbarView: {
            ZStack {
                Color.red.ignoresSafeArea()
                Text("tabbar")
            }
            },
            onboardingView: {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("onboarding")
                }
            }
        )
        .onTapGesture {
           showTabBar.toggle()
        }
    }
}

#Preview {
    PreviewView()
}
