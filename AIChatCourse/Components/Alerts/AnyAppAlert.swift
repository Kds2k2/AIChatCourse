//
//  AnyAppAlert.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 05.01.2026.
//

import SwiftUI

struct AnyAppAlert {
    var title: String?
    var subtitle: String?
    var buttons: () -> AnyView
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        buttons: (() -> AnyView)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons ?? {
            AnyView(
                Button("OK") {
                    // action
                }
            )
        }
    }
    
    init(error: Error) {
        self.init(
            title: "Error",
            subtitle: error.localizedDescription,
            buttons: nil
        )
    }
}

enum AlertType {
    case alert, confirmationDialog
}

extension View {
    
    @ViewBuilder
    func showCustomAlert(type: AlertType = .alert, alert: Binding<AnyAppAlert?>) -> some View {
        switch type {
        case .alert:
            self
                .alert(alert.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: alert)) {
                    alert.wrappedValue?.buttons()
                } message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
        case .confirmationDialog:
            self
                .confirmationDialog("", isPresented: Binding(ifNotNil: alert)) {
                    alert.wrappedValue?.buttons()
                } message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
        }
    }
}
