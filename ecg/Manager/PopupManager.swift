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

    // 로딩 문구
    @Published var loadingTitle: String?
    @Published var loadingSubtitle: String?
    
    struct PopupConfig {
        var title: String
        var messageHeader: String
        var messages: [String]
        var confirmTitle: String
        var cancelTitle: String?
        var onConfirm: () -> Void
        var onCancel: (() -> Void)?

        // ✅ 추가된 필드
        var showProgressBar: Bool = false
        var progress: Double? = nil  // 0.0 ~ 1.0
        var progressTitleProvider: ((Double) -> String)? = nil
    }


    func showPopup(
        title: String,
        messageHeader: String = "",
        messages: [String] = [],
        confirmTitle: String = "확인",
        cancelTitle: String? = nil,
        onConfirm: @escaping () -> Void = {},
        onCancel: (() -> Void)? = nil,
        showProgressBar: Bool = false,
        progress: Double? = nil,
        progressTitleProvider: ((Double) -> String)? = nil
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
            },
            showProgressBar: showProgressBar,
            progress: progress,
            progressTitleProvider: progressTitleProvider
        )
    }

    func hidePopup() {
        popup = nil
    }

    // 로딩 제어
    func showLoading(title: String = "", subtitle: String = "") {
        loadingTitle = title
        loadingSubtitle = subtitle
        isLoading = true
    }

    func hideLoading() {
        isLoading = false
    }
}
