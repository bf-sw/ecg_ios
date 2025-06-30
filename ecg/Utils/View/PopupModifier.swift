//
//  PopupModifier.swift
//  ecg
//
//  Created by insung on 5/23/25.
//

import SwiftUI

struct PopupModifier: ViewModifier {
    @ObservedObject var manager = PopupManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            if manager.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                LoadingView(
                    title: manager.loadingTitle ?? "",
                    subtitle: manager.loadingSubtitle ?? ""
                )
                .transition(.opacity)
            }
            
            if let config = manager.popup {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                PopupView(config: config) {
                    manager.hidePopup()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: manager.isLoading || manager.popup != nil)
    }
}
