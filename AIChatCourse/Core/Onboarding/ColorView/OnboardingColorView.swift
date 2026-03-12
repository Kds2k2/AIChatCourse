//
//  OnboardingColorView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 01.01.2026.
//

import SwiftUI

struct OnboardingColorView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingColorViewModel
    @Binding var path: [OnboardingPathOption]

    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16, content: {
            ZStack {
                if let selectedColor = viewModel.selectedColor {
                    ctaButton(selectedColor: selectedColor)
                        .transition(.move(edge: .bottom))
                }
            }
            .padding(24)
            .background(.background)
        })
        .animation(.smooth, value: viewModel.selectedColor)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingColorView")
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), // Horizontal spacing
            alignment: .center,
            spacing: 16, // Vertical spacing
            pinnedViews: [.sectionHeaders],
            content: {
                Section(content: {
                    ForEach(viewModel.profileColor, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay(
                                color
                                    .clipShape(Circle())
                                    .padding(viewModel.selectedColor == color ? 10 : 0)
                            )
                            .onTapGesture {
                                viewModel.onColorPressed(color: color)
                            }
                            .accessibilityIdentifier("ColorCircle")
                    }
                }, header: {
                    Text("Select a profile color")
                        .font(.headline)
                })
            }
        )
    }
    
    private func ctaButton(selectedColor: Color) -> some View {
            Text("Continue")
                .callToActionButton()
                .accessibilityIdentifier("ContinueButton")
                .anyButton(.press) {
                    viewModel.onContinuePressed(selectedColor: selectedColor, path: $path)
                }
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView(viewModel: OnboardingColorViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), path: .constant([]))
    }
    .previewEnvironment()
}
