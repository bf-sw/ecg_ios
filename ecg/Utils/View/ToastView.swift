//
//  ToastView.swift
//  ecg
//
//  Created by insung on 5/23/25.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .multilineTextAlignment(.center)
            .font(.desciptionFont)
            .padding(24)
            .background(Color.primaryColor)
            .foregroundColor(.surfaceColor)
            .cornerRadius(10)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .padding(.bottom, 60)
    }
}

#Preview {
    ToastView(message: "토스트 메세지 입니다.")
}
