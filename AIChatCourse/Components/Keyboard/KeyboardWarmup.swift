//
//  KeyboardWarmup.swift
//  SquatsCounter
//
//  Created by Dmitro Kryzhanovsky on 21.10.2025.
//

import SwiftUI

@MainActor
final class KeyboardWarmup {
    static func warmupInBackground() {
        _ = UITextInputMode.activeInputModes
        _ = UITextChecker()

        let textField = UITextField()
        textField.frame = CGRect(x: -10000, y: -10000, width: 1, height: 1)
        textField.isHidden = true
        textField.alpha = 0.0

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(textField)

            textField.becomeFirstResponder()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                textField.resignFirstResponder()
                textField.removeFromSuperview()
            }
        }
    }
}
