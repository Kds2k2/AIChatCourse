//
//  FloatingSecureTextField.swift
//  SparkApp
//
//  Created by Dmitro Kryzhanovsky on 23.11.2025.
//

import SwiftUI

struct FloatingTextField: View {
    
    @Environment(\.floatingTextFieldForeground) private var foregroundColor
    @Environment(\.floatingTextFieldBackground) private var backgroundColor
    @Environment(\.floatingTextFieldBorder) private var borderColor
    @Environment(\.floatingTextFieldIcon) private var iconColor

    enum FloatingTextFieldType {
        case normal, secure
        
        static var `default`: Self {
            return .normal
        }
    }
    
    var leftIcon: String?
    var rightIcon: String?
    var placeholder: String
    var type: FloatingTextFieldType = .default
    
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var isSecure: Bool = true
    
    private var isFloated: Bool {
        isFocused || !text.isEmpty
    }
    
    private var placeholderXOffset: CGFloat {
        isFloated ? 15 : (leftIcon != nil ? 45 : 15)
    }

    private var placeholderYOffset: CGFloat {
        isFloated ? -30 : 0
    }
    
    init(
        text: Binding<String>,
        placeholder: String,
        leftIcon: String? = nil,
        rightIcon: String? = nil,
        type: FloatingTextFieldType = .normal
    ) {
        self._text = text
        self.placeholder = placeholder
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.type = type
    }
    
    init(
        text: Binding<String>,
        placeholder: String,
        leftIcon: String? = nil,
        rightIcon: String? = nil
    ) {
        self.init(
            text: text,
            placeholder: placeholder,
            leftIcon: leftIcon,
            rightIcon: rightIcon,
            type: .default
        )
    }
    
    init(
        secureText text: Binding<String>,
        placeholder: String = "Password",
        leftIcon: String? = "lock.fill"
    ) {
        self.init(
            text: text,
            placeholder: placeholder,
            leftIcon: leftIcon,
            rightIcon: nil,
            type: .secure
        )
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            fieldContainer
            floatingPlaceholder
        }
        .padding(.top, 15)
        .background(backgroundColor)
    }
    
    // MARK: - Some View
    private var fieldContainer: some View {
        HStack {
            leftIconView
            inputView
            rightAccessory
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8)
            .stroke(borderColor))
    }
    
    @ViewBuilder
    private var leftIconView: some View {
        if leftIcon != nil {
            Image(systemName: leftIcon ?? "person")
                .foregroundStyle(iconColor)
        }
    }
    
    @ViewBuilder
    private var inputView: some View {
        switch type {
        case .normal:
            textField

        case .secure:
            ZStack {
                secureField
                textField
            }
        }
    }
    
    private var textField: some View {
        TextField("", text: $text)
            .foregroundStyle(foregroundColor)
            .tint(foregroundColor)
            .background(backgroundColor)
            .opacity(isSecure ? 1 : 0)
            .focused($isFocused)
    }

    private var secureField: some View {
        SecureField("", text: $text)
            .foregroundStyle(foregroundColor)
            .tint(foregroundColor)
            .background(backgroundColor)
            .opacity(isSecure ? 0 : 1)
            .focused($isFocused)
    }
    
    @ViewBuilder
    private var rightAccessory: some View {
        switch type {
        case .normal:
            if let rightIcon {
                Image(systemName: rightIcon)
                    .foregroundStyle(iconColor)
            }

        case .secure:
            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(iconColor)
            }
            .animation(.smooth, value: isSecure)
        }
    }
    
    private var floatingPlaceholder: some View {
        Text(placeholder)
            .foregroundStyle(borderColor)
            .background(backgroundColor)
            .padding(-3)
            .offset(x: placeholderXOffset, y: placeholderYOffset)
            .animation(.easeInOut(duration: 0.22), value: isFloated)
            .onTapGesture { isFocused = true }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    
    FloatingTextField(
        text: $text,
        placeholder: "Email",
        leftIcon: "person",
        rightIcon: nil
    )
    
    FloatingTextField(secureText: $text)
    
    FloatingTextField(secureText: $text)
        .textFieldForegroundColor(
            foregroundColor: .teal,
            backgroundColor: .black,
            borderColor: .teal,
            iconColor: .teal
        )
}
