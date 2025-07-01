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
                VStack(spacing: 20) {
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

                    // ✅ 진행률 바 추가 영역
                    if config.showProgressBar, let progress = config.progress {
                        VStack() {
                            ProgressView(value: progress)
                                
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(height: 10)
                                .tint(.customPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .clipShape(Capsule())

                            Text("\(Int(progress * 100))%")
                                .font(.popupDescriptionFont)
                        }
                        .padding(.top, 20)
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
            .frame(maxWidth: 820, maxHeight: 520)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.onSurfaceColor)
            .cornerRadius(16)
        }
    }
}


#Preview {
    PopupView(config: PopupManager.PopupConfig(
        title: "업로드 중",
        messageHeader: "파일을 서버에 업로드하고 있습니다",
        messages: ["Wi-Fi 상태를 확인하세요", "작업 중 창을 닫지 마세요"],
        confirmTitle: "확인",
        cancelTitle: "취소",
        onConfirm: { print("확인 클릭됨") },
        onCancel: { print("취소 클릭됨") },
        showProgressBar: true,
        progress: 1.0,
        progressTitleProvider: { progress in
            return progress < 1.0 ? "진행 중..." : "완료됨"
        }
    ), onDismiss: {
        print("팝업 닫힘")
    })
}
