//
//  SecureTextField.swift
//  ecg
//
//  Created by insung on 5/14/25.
//

import SwiftUI

struct SecureTextField: View {
    var placeholder: String
    @Binding var text: String

    // 사용자 실제 입력을 임시로 저장하는 내부 상태
    @State private var internalText: String = ""

    var body: some View {
        TextField(placeholder, text: $internalText)
            .keyboardType(.numberPad)
            .foregroundColor(.clear)
            .accentColor(.clear)
            .onChange(of: internalText) { newValue in
                // 숫자만 필터링
                let filtered = newValue.filter { $0.isNumber }

                // 4자리까지만 허용
                if filtered.count > 4 {
                    internalText = String(filtered.prefix(4))
                } else {
                    internalText = filtered
                }

                // 실제 외부로 전달되는 text는 마스킹 없이 숫자 그대로 저장
                text = internalText
            }
            .overlay(
                // 마스킹된 텍스트 표시
                HStack {
                    Text(String(repeating: "●", count: internalText.count))
                        .padding(.horizontal, 4)
                    Spacer()
                }
            )
    }
}
