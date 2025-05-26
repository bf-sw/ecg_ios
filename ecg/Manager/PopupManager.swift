//
//  PopupManager.swift
//  ecg
//
//  Created by insung on 4/22/25.
//

import Foundation
import Combine

class PopupManager: ObservableObject {
    static let shared = PopupManager()

    // 팝업 상태
    @Published var popup: PopupConfig? = nil

    // 로딩 상태
    @Published var isLoading: Bool = false

    struct PopupConfig {
        var title: String
        var messageHeader: String
        var messages: [String]
        var confirmTitle: String
        var cancelTitle: String?
        var onConfirm: () -> Void
        var onCancel: (() -> Void)?
    }

    func showPopup(
        title: String,
        messageHeader: String = "",
        messages: [String] = [],
        confirmTitle: String = "확인",
        cancelTitle: String? = nil,
        onConfirm: @escaping () -> Void = {},
        onCancel: (() -> Void)? = nil
    ) {
        popup = PopupConfig(
            title: title,
            messageHeader: messageHeader,
            messages: messages,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            onConfirm: {
                self.hidePopup()
                onConfirm()
            },
            onCancel: {
                self.hidePopup()
                onCancel?()
            }
        )
    }

    func hidePopup() {
        popup = nil
    }

    // 로딩 제어
    func showLoading() {
        isLoading = true
    }

    func hideLoading() {
        isLoading = false
    }
}
