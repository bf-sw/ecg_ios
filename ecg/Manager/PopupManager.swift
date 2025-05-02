//
//  PopupManager.swift
//  ecg
//
//  Created by insung on 4/22/25.
//

import SwiftUI

class PopupManager: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var config: PopupConfig = .default

    struct PopupConfig {
        var title: String
        var messageHeader: String
        var messages: [String]
        var confirmTitle: String
        var cancelTitle: String?
        var onConfirm: () -> Void
        var onCancel: (() -> Void)?
        
        static var `default`: PopupConfig {
            PopupConfig(
                title: "", messageHeader: "", messages: [],
                confirmTitle: "확인", cancelTitle: nil,
                onConfirm: {}, onCancel: nil
            )
        }
    }

    func showPopup(config: PopupConfig) {
        self.config = config
        isShowing = true
    }

    func hidePopup() {
        isShowing = false
    }
}
