//
//  PopupView.swift
//  ecg
//
//  Created by insung on 4/22/25.
//

import SwiftUI

struct PopupView: View {
    let config: PopupManager.PopupConfig
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 40) {
                    Text(config.title)
                        .font(.popupHeaderFont)

                    Text(config.messageHeader)
                        .multilineTextAlignment(.center)
                        .font(.popupTitleFont)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(config.messages.indices, id: \.self) { index in
                            Text(config.messages[index])
                                .font(.popupDescriptionFont)
                        }
                    }
                }
                .padding(40)
                
                Divider()
                
                HStack {
                    if let cancelTitle = config.cancelTitle, let onCancel = config.onCancel {
                        Button(action: onCancel) {
                            Text(cancelTitle)
                                .font(.popupDescriptionFont)
                                .foregroundColor(.surfaceColor)
                                .frame(maxWidth: .infinity)
                        }

                        Divider()
                    }

                    Button(action: config.onConfirm) {
                        Text(config.confirmTitle)
                            .foregroundColor(.primaryColor)
                            .font(.popupDescriptionFont)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 86)
            }
            .frame(maxWidth: 820, maxHeight: 480)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.onSurfaceColor)
            .cornerRadius(16)
        }
    }
}


#Preview {
    PopupView(config: PopupManager.PopupConfig(
        title: "미리보기 팝업",
        messageHeader: "이것은 헤더입니다",
        messages: ["첫 번째 메시지", "두 번째 메시지"],
        confirmTitle: "확인",
        cancelTitle: "취소",
        onConfirm: { print("확인 클릭됨") },
        onCancel: { print("취소 클릭됨") }
    ),
    onDismiss: {
        print("팝업 닫힘")
    })
}
