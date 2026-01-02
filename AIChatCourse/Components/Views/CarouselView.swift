//
//  CarouselView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 02.01.2026.
//

import SwiftUI

struct CarouselView<Content: View, T: Hashable>: View {

    var items: [T]
    @ViewBuilder var content: (T) -> Content
    @State private var selection: T?

    var body: some View {
        VStack(spacing: 12) {
            carousel
            pageIndicator
        }
    }
    
    private var carousel: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    content(item)
                        .scrollTransition(.interactive.threshold(.visible(0.95)), transition: { content, phase in
                            content.scaleEffect(phase.isIdentity ? 1 : 0.9)
                        })
                        .containerRelativeFrame(.horizontal, alignment: .center)
                        .id(item)
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: 200)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $selection)
        .onChange(of: items.count, { _, _ in
            updateSelectionIfNeeded()
        })
        .onAppear {
            updateSelectionIfNeeded()
        }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Circle()
                    .fill(item == selection ? .accent : .secondary.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
        .animation(.linear, value: selection)
    }
    
    private func updateSelectionIfNeeded() {
        if selection == nil || selection == items.last {
            selection = items.first
        }
    }
}

#Preview {
    CarouselView(items: AvatarModel.mocks, content: { item in
        HeroCellView(
            title: item.name,
            subtitle: item.characterDescription,
            imageName: item.profileImageName,
            lineWidth: 1.0
        )
    })
}
