//
//  LoadingView.swift
//  ecg
//
//  Created by insung on 4/21/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            // 어두운 반투명 배경
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 60) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.orange))
                    .scaleEffect(2.5)
                
                VStack(spacing: 4) {
                    Text("기기와 연결 중입니다.")
                        .font(.subtitleFont)
                        .foregroundColor(.surfaceColor)
                    Text("잠시만 기다려 주세요.")
                        .font(.subtitleFont)
                        .foregroundColor(.surfaceColor)
                }
            }
            .frame(minWidth: 430, minHeight: 250)
            .padding(40)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

#Preview {
    LoadingView()
}
