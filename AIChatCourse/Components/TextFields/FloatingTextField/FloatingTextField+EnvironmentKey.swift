//
//  FloatingTextField+EnvironmentKey.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 09.01.2026.
//

import SwiftUI

// MARK: - Keys
private struct FloatingTextFieldForegroundKey: EnvironmentKey {
    static let defaultValue: Color = .primary
}

private struct FloatingTextFieldBackgroundKey: EnvironmentKey {
    static let defaultValue: Color = Color(uiColor: .systemBackground)
}

private struct FloatingTextFieldBorderKey: EnvironmentKey {
    static let defaultValue: Color = .secondary
}

private struct FloatingTextFieldIconKey: EnvironmentKey {
    static let defaultValue: Color = .secondary
}

// MARK: - Values
extension EnvironmentValues {
    var floatingTextFieldForeground: Color {
        get { self[FloatingTextFieldForegroundKey.self] }
        set { self[FloatingTextFieldForegroundKey.self] = newValue }
    }
    
    var floatingTextFieldBackground: Color {
        get { self[FloatingTextFieldBackgroundKey.self] }
        set { self[FloatingTextFieldBackgroundKey.self] = newValue }
    }

    var floatingTextFieldBorder: Color {
        get { self[FloatingTextFieldBorderKey.self] }
        set { self[FloatingTextFieldBorderKey.self] = newValue }
    }

    var floatingTextFieldIcon: Color {
        get { self[FloatingTextFieldIconKey.self] }
        set { self[FloatingTextFieldIconKey.self] = newValue }
    }
}

// MARK: - Modifier
struct FloatingTextFieldAppearance: ViewModifier {
    let foreground: Color
    let background: Color
    let border: Color
    let icon: Color
    
    func body(content: Content) -> some View {
        content
            .environment(\.floatingTextFieldForeground, foreground)
            .environment(\.floatingTextFieldBackground, background)
            .environment(\.floatingTextFieldBorder, border)
            .environment(\.floatingTextFieldIcon, icon)
    }
}

// MARK: - View extension
extension View {
    func textFieldForegroundColor(
        foregroundColor: Color,
        backgroundColor: Color? = nil,
        border: Color? = nil,
        icon: Color? = nil
    ) -> some View {
        modifier(
            FloatingTextFieldAppearance(
                foreground: foregroundColor,
                background: backgroundColor ?? Color(uiColor: .systemBackground),
                border: border ?? foregroundColor.opacity(0.5),
                icon: icon ?? foregroundColor.opacity(0.7)
            )
        )
    }
}

private struct PreviewView: View {
    @State var text: String = ""
    
    var body: some View {
        FloatingTextField(
            text: $text,
            placeholder: "Email",
            leftIcon: "person",
            rightIcon: "person"
        )
        .textFieldForegroundColor(
            foregroundColor: .white,
            border: .accent,
            icon: .accent
        )
        
        FloatingTextField(secureText: $text)
        .textFieldForegroundColor(
            foregroundColor: .blue,
            backgroundColor: .red,
            border: .green,
            icon: .purple
        )
    }
}

#Preview {
    @Previewable @State var text: String = ""
    
    PreviewView(text: text)
}
