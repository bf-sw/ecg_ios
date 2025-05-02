//
//  PopupView.swift
//  ecg
//
//  Created by insung on 4/22/25.
//

import SwiftUI

struct PopupView: View {
    let title: String
    let messageHeader: String
    let messages: [String]
    let confirmTitle: String
    let cancelTitle: String?
    let onConfirm: () -> Void
    let onCancel: (() -> Void)?

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 40) {
                    Text(title)
                        .font(.popupHeaderFont)

                    Text(messageHeader)
                        .multilineTextAlignment(.center)
                        .font(.popupTitleFont)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(messages.indices, id: \.self) { index in
                            Text(messages[index])
                                .font(.popupDescriptionFont)
                        }
                    }
                }
                .padding(40)
                
                Divider()
                
                HStack {
                    if let cancelTitle = cancelTitle, let onCancel = onCancel {
                        Button(action: onCancel) {
                            Text(cancelTitle)
                                .font(.popupDescriptionFont)
                                .foregroundColor(.surfaceColor)
                                .frame(maxWidth: .infinity)
                        }

                        Divider()
                    }

                    Button(action: onConfirm) {
                        Text(confirmTitle)
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
    PopupView(
        title: "타이틀",
        messageHeader: "헤더",
        messages: ["내용1", "1. 내용2"],
        confirmTitle: "확인",
        cancelTitle: "취소",
        onConfirm: {
            
        },
        onCancel: {
            
        }
    )
}
