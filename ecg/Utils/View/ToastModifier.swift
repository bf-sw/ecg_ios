//
//  ToastModifier.swift
//  ecg
//
//  Created by insung on 5/23/25.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager = ToastManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            if let message = toastManager.message {
                VStack {
                    Spacer()
                    ToastView(message: message)
                }
                .animation(.easeInOut(duration: 0.3), value: toastManager.message)
                .transition(.opacity)
            }
        }
    }
}
