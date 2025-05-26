//
//  View+Extension.swift
//  ecg
//
//  Created by insung on 4/11/25.
//

import SwiftUI

extension View {
    
    // 그림자 추가
    func boxShadow(color: Color = Color.onSurfaceColor) -> some View {
        return self
                .background(color)
                .cornerRadius(10)
                .shadow(color: Color.shadowColor, radius: 20)
    }
    
    // 라운드 추가
    func boxRounded(color: Color = Color.onSurfaceColor) -> some View {
        return self
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.surfaceColor, lineWidth: 1)
            )
    }
    
    // 토스트 기능 추가
    func toast() -> some View {
        self.modifier(ToastModifier())
    }
    
    // 팝업 기능 추가
    func popup() -> some View {
        self.modifier(PopupModifier())
    }
}
