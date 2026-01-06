//
//  ModalSupportView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 06.01.2026.
//

import SwiftUI

struct ModalSupportView<Content: View>: View {
    
    @Binding var showModal: Bool
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            if showModal {
                Color.black.opacity(0.6).ignoresSafeArea()
                    .transition(AnyTransition.opacity.animation(.smooth))
                    .onTapGesture {
                        showModal = false
                    }
                    .zIndex(1)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(2)
            }
        }
        .zIndex(9999)
        .animation(.bouncy, value: showModal)
    }
}

extension View {
    func showModal(_ showModal: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        self
            .overlay {
                ModalSupportView(showModal: showModal) {
                    content()
                }
            }
    }
}

private struct PreviewView<Content: View>: View {
    
    @State private var showModal: Bool = false
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            Button("Show Modal") {
                showModal = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .showModal($showModal) {
                content
                    .transition(.slide)
                    .onTapGesture {
                        showModal = false
                    }
            }
        }
    }
}

#Preview("Text") {
    PreviewView {
        Text("Some text")
            .foregroundStyle(.accent)
    }
}

#Preview("Rectangle") {
    PreviewView {
        RoundedRectangle(cornerRadius: 30)
            .padding(40)
            .padding(.vertical, 100)
    }
}
